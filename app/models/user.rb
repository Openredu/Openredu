# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  include Invitable::Base
  include Humanizer
  include UserSearchable
  include EnrollmentService::BaseModelAdditions
  include EnrollmentService::UserAdditions::ModelAdditions
  include StatusService::BaseModelAdditions
  include StatusService::UserAdditions::ModelAdditions
  include DestroySoon::ModelAdditions

  # Valida a resposta ao captcha
  attr_writer :enable_humanizer
  require_human_on :create, if: :enable_humanizer

  require 'community_engine_sha1_crypto_method'
  require 'paperclip'

  # Constants
  MALE    = 'M'
  FEMALE  = 'F'
  MIN_LOGIN_LENGTH = 5
  MAX_LOGIN_LENGTH = 20
  REQUIRED_USER_EMAIL_DOMAIN_ENVAR = 'APP_REQUIRED_USER_EMAIL_DOMAIN'

  # CALLBACKS
  before_create :make_activation_code
  after_create  :update_last_login, :activate
  before_validation :strip_whitespace
  after_commit on: :create do
    environment = Environment.find_by_path('ava-redu')
    environment.courses.each { |c| c.join(self) } if environment
    UserNotifier.delay(queue: 'email', priority: 1).user_signedup(self.id)
  end

  # ASSOCIATIONS
  # Space
  has_many :spaces, through: :user_space_associations,
    conditions: ["spaces.destroy_soon = ?", false]
  has_many :user_space_associations, dependent: :destroy
  has_many :spaces_owned, class_name: "Space" , foreign_key: "user_id"
  # Environment
  has_many :user_environment_associations, dependent: :destroy
  has_many :environments, through: :user_environment_associations,
    conditions: ["environments.destroy_soon = ?", false]
  has_many :user_course_associations, dependent: :destroy
  has_many :course_enrollments, dependent: :destroy
  has_many :environments_owned, class_name: "Environment",
    foreign_key: "user_id"
  # Course
  has_many :courses, through: :user_course_associations,
    conditions: ["courses.destroy_soon = ? AND
                    course_enrollments.state = ?", false, 'approved']
  # Authentication
  has_many :authentications, dependent: :destroy

  #COURSES
  has_many :lectures, foreign_key: "user_id",
    conditions: {is_clone: false}
  has_many :courses_owned, class_name: "Course",
    foreign_key: "user_id"
  classy_enum_attr :role, default: 'member'
  has_many :enrollments
  has_many :asset_reports, through: :enrollments

  #subject
  has_many :subjects, order: 'name ASC',
    conditions: { finalized: true }

  has_many :plans
  has_many :course_invitations, class_name: "UserCourseAssociation",
    conditions: ["state LIKE 'invited'"]
  has_many :experiences, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_one :settings, class_name: "TourSetting", dependent: :destroy

  has_many :social_networks, dependent: :destroy

  has_many :logs, as: :logeable, order: "created_at DESC",
    dependent: :destroy
  has_many :statuses, as: :statusable, order: "updated_at DESC"
  has_many :overview, through: :status_user_associations, source: :status,
    include: [:user, :answers], order: "updated_at DESC"
  has_many :status_user_associations

  has_many :client_applications
  has_many :tokens, class_name: "OauthToken", order: "authorized_at desc", include: [:client_application]
  has_many :results, dependent: :destroy
  has_many :choices, dependent: :delete_all

  #Chat
  has_many :conversations, foreign_key: :sender_id

  # Named scopes
  scope :recent, order('users.created_at DESC')
  scope :active, where("users.activated_at IS NOT NULL")
  scope :with_ids, lambda { |ids| where(id: ids) }
  scope :without_ids, lambda {|ids|
    where("users.id NOT IN (?)", ids)
  }
  scope :with_keyword, lambda { |keyword|
    where("LOWER(login) LIKE :keyword OR " + \
      "LOWER(first_name) LIKE :keyword OR " + \
      "LOWER(last_name) LIKE :keyword OR " + \
      "CONCAT(TRIM(LOWER(first_name)), ' ', TRIM(LOWER(last_name))) LIKE :keyword OR " + \
      "LOWER(email) LIKE :keyword", { keyword: "%#{keyword.to_s.downcase}%" }).
      limit(10).select("users.id, users.first_name, users.last_name, users.login, users.email, users.avatar_file_name, users.avatar_updated_at")
  }
  scope :popular, lambda { |quantity|
    order('friends_count desc').limit(quantity)
  }

  scope :popular_teachers, lambda { |quantity|
    includes(:user_course_associations).
      where("course_enrollments.role" => Role[:teacher]).popular(quantity)
  }
  scope :with_email_domain_like, lambda { |email|
    where("email LIKE ?", "%#{email.to_s.split("@")[1]}%")
  }
  scope :contacts_and_pending_contacts_ids , select("users.id").
    joins("LEFT OUTER JOIN `friendships`" \
            " ON `friendships`.`friend_id` = `users`.`id`").
    where("friendships.status = 'accepted'" \
          " OR friendships.status = 'pending'" \
          " OR friendships.status = 'requested'")

  scope :message_recipients, lambda { |recipients_ids| where("users.id IN (?)", recipients_ids) }

  attr_accessor :email_confirmation

  # Accessors
  attr_protected :admin, :role, :activation_code, :friends_count, :score,
    :removed

  accepts_nested_attributes_for :settings
  accepts_nested_attributes_for :social_networks,
    reject_if: proc { |attributes| attributes['url'].blank? or
      attributes['name'].blank? },
    allow_destroy: true

  # PLUGINS
  acts_as_authentic do |c|
    c.crypto_provider = CommunityEngineSha1CryptoMethod
    c.validate_login_field = false
    c.validate_password_field = false
    c.validate_email_field = false
  end

  has_attached_file :avatar, Redu::Application.config.paperclip_user

  has_friends
  ajaxful_rater
  acts_as_taggable
  has_private_messages

  # VALIDATIONS
  validates_presence_of :first_name, :last_name
  validates :birthday, allow_nil: true,
            date: { before: Proc.new { 13.years.ago } }
  validates_acceptance_of :tos
  validates_format_of :mobile,
                      with: /^\+\d{2}\s\(\d{2}\)\s\d{4,5}-\d{3,4}$/,
                      allow_blank: true
  validates_format_of :first_name, with: /^\S(\S|\s)*\S$/
  validates_format_of :last_name, with: /^\S(\S|\s)*\S$/
  validates_length_of :first_name, maximum: 25
  validates_length_of :last_name, maximum: 25
  validates :password,
    length: { minimum: 6, maximum: 20 },
    confirmation: true,
    if: :password_required?
  validates :login,
    exclusion: { in: Redu::Application.config.extras["reserved_logins"] },
    format: { with: /^[A-Za-z0-9_-]*[A-Za-z]+[A-Za-z0-9_-]*$/ },
    length: { minimum: MIN_LOGIN_LENGTH, maximum: MAX_LOGIN_LENGTH }
  validates_uniqueness_of :login, case_sensitive: false
  validates :email,
    format: { with: /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/ },
    length: { minimum: 3, maximum: 100 },
    confirmation: true
  validates_uniqueness_of :email, case_sensitive: false
  validate :email_has_valid_domain

  delegate :can?, :cannot?, to: :ability

  class << self
    # override activerecord's find to allow us to find by name or id transparently
    def find(*args)
      if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
        find_by_login(args)
      else
        super
      end
    end

    def find_by_login_or_email(login)
      User.find_by_login(login) || User.find_by_email(login)
    end

    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
  end

  def process_invitation!(invitee, invitation)
    self.be_friends_with(invitee)
    invitation.delete
  end

  def profile_complete?
    (self.first_name and self.last_name and self.gender and
        self.description and self.tags) ? true : false
  end

  def can_manage?(entity)
    entity.nil? and return false
    self.admin? and return true
    self.environment_admin? entity and return true

    case entity.class.to_s
    when 'Course'
      (self.environment_admin? entity.environment)
    when 'Space'
      self.teacher?(entity) || self.can_manage?(entity.course) || self.teacher?(entity.course)
    when 'Subject'
      self.teacher?(entity.space) || self.can_manage?(entity.space)
    when 'Lecture'
      teacher?(entity.subject.space) || can_manage?(entity.subject)
    when 'Exam'
      self.teacher?(entity.subject.space) || self.can_manage?(entity.space)
    when 'Folder'
      self.teacher?(entity.space) || self.tutor?(entity.space) || self.can_manage?(entity.space)
    when 'Topic'
      self.member?(entity.space)
    when 'SbPost'
      self.member?(entity.space)
    when 'Status', 'Activity', 'Answer', 'Help'
      if self == entity.user
        true
      else
        case entity.statusable.class.to_s
        when 'Space'
          self.teacher?(entity.statusable) ||
            self.can_manage?(entity.statusable)
        when 'Subject'
          self.teacher?(entity.statusable.space) ||
            self.can_manage?(entity.statusable.space)
        when 'Lecture'
          self.can_manage?(entity.statusable.subject)
        when 'Answer', 'Activity', 'Help'
          self.can_manage?(entity.statusable)
        end
      end
    when 'User'
      entity == self
    when 'Plan', 'PackagePlan', 'LicensedPlan'
      entity.user == self || self.can_manage?(entity.billable)
    when 'Myfile'
      self.can_manage?(entity.folder)
    when 'Friendship'
      # user_id necessário devido ao bug do create_time_zone
      self.id == entity.user_id
    when 'Experience'
      self.can_manage?(entity.user)
    when 'SocialNetwork'
      self.can_manage?(entity.user)
    when 'Education'
      self.can_manage?(entity.user)
    when 'Result'
      self.can_manage?(entity.exercise)
    when 'Exercise'
      self.can_manage?(entity.lecture) && !entity.has_results?
    when 'Invitation'
      self.can_manage?(entity.hostable)
    end
  end

  def has_access_to?(entity)
    self.admin? and return true

    if self.get_association_with(entity)
      # Apenas Course tem state
      if entity.class.to_s == 'Course' &&
        !self.get_association_with(entity).approved?
        return false
      else
        return true
      end
    else
      case entity
      when Folder
        self.get_association_with(entity.space).nil? ? false : true
      when Status
        if entity.statusable.is_a? User
          self.friends?(entity.statusable) || self == entity.statusable
        else
          self.has_access_to? entity.statusable
        end
      when Help
        has_access_to?(entity.statusable)
      when Lecture
        self.has_access_to? entity.subject
      when Result
        entity.user == self
      when Question
        has_access_to? entity.exercise.lecture
      else
        return false
      end
    end
  end

  def enrolled?(subject)
    self.get_association_with(subject).nil? ? false : true
  end

  # Método de alto nível, verifica se o object está publicado (caso se aplique)
  # e se o usuário possui acesso (i.e. relacionamento) com o mesmo
  def can_read?(object)
    if (object.is_a? Folder)  ||
       (object.is_a? Status) || (object.is_a? Help) ||
       (object.is_a? User) || (object.is_a? Friendship) ||
       (object.is_a? Plan) || (object.is_a? PackagePlan) ||
        (object.is_a? Result) || (object.is_a? Question) ||
        (object.is_a? Lecture)

      self.has_access_to?(object)
    else
      if (object.is_a? Subject)
        object.visible? && self.has_access_to?(object)
      else
        object.published? && self.has_access_to?(object)
      end
    end
  end

  def to_param
    login
  end

  def deactivate
    return if admin? #don't allow admin deactivation
    @activated = false
    update_attributes(activated_at: nil, activation_code: make_activation_code)
  end

  def activate
    @activated = true
    update_attributes(activated_at: Time.now.utc, activation_code: nil)
  end

  # Indica se o usuário ainda pode utilizar o Redu sem ter ativado a conta
  def can_activate?
    activated_at.nil? and created_at > 30.days.ago
  end

  def active?
    #FIXME Workaround para quando o active? é chamado e o usuário não exite
    # (authlogic)
    return false unless created_at
    ( activated_at.nil? and (created_at < (Time.now - 30.days))) ? false : true
  end

  def encrypt(password)
    self.class.encrypt(password, self.password_salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def reset_password
    new_password = newpass(8)
    self.password = new_password
    self.password_confirmation = new_password
    return self.valid?
  end

  def owner
    self
  end

  def update_last_login
    self.save #FIXME necessário para que o last_login_at seja atualizado, #419
    self.update_attribute(:last_login_at, Time.now)
  end

  def display_name
    if self.removed?
      return '(usuário removido)'
    end

    if self.first_name and self.last_name
      self.first_name + " " + self.last_name
    else
      login
    end

  end

  # Cria associação do agrupamento de amizade do usuário para seus amigos
  # e para o pŕoprio usuário (home_activity)
  def notify(compound_log)
    self.status_user_associations.create(status: compound_log)
    Status.associate_with(compound_log, self.friends.select('users.id'))
  end

  # Pega associação com Entity (aplica-se a Environment, Course, Space e Subject)
  def get_association_with(entity)
    return false unless entity

    case entity.class.to_s
    when 'Space'
      self.user_space_associations.
        find(:first, conditions: { space_id: entity.id })
    when 'Course'
      self.user_course_associations.
        find(:first, conditions: { course_id: entity.id })
    when 'Environment'
      self.user_environment_associations.
        find(:first, conditions: { environment_id: entity.id })
    when 'Subject'
      self.enrollments.
        find(:first, conditions: { subject_id: entity.id })
    when 'Lecture'
      self.enrollments.
        find(:first, conditions: { subject_id: entity.subject.id })
    when 'Activity', 'Help', 'Status', 'Log'
      self.status_user_associations.
        find(:first, conditions: { status_id: entity.id })
    end
  end

  def environment_admin?(entity)
    return false if entity.is_a? Status
    association = get_association_with entity
    association && association.role && association.role.environment_admin?
  end

  def admin?
    @is_admin ||= role.admin?
  end

  def teacher?(entity)
    association = get_association_with entity
    return false if association.nil?
    association && association.role && association.role.teacher?
  end

  def teacher_in_this_environment?(environment)
    is_teacher = false;

    environment.course_ids.each do |course_id|
      is_teacher = self.teacher?(Course.find(course_id))
      break if is_teacher == true;
    end

    is_teacher
  end

  def tutor?(entity)
    association = get_association_with entity
    return false if association.nil?
    association && association.role && association.role.tutor?
  end

  def member?(entity)
    association = get_association_with entity
    return false if association.nil?
    association && association.role && association.role.member?
  end

  def male?
    gender && gender.eql?(MALE)
  end

  def female?
    gender && gender.eql?(FEMALE)
  end

  def home_activity(page = 1)
    associateds = [:status_resources, { answers: [:user, :status_resources] },
                   :user, :logeable, :statusable]
    overview.where(compound: false).includes(associateds).
      page(page).per(Redu::Application.config.items_per_page)
  end

  def profile_for(subject)
    self.enrollments.where(subject_id: subject)
  end

  def completeness
    total = 16.0
    undone = 0.0
    undone += 1 if self.description.to_s.empty?
    undone += 1 if self.avatar_file_name.nil?
    undone += 1 if self.gender.nil?
    undone += 1 if self.localization.to_s.empty?
    undone += 1 if self.birth_localization.to_s.empty?
    undone += 1 if self.languages.to_s.empty?
    undone += 1 if self.tags.empty?
    undone += 1 if self.mobile.to_s.empty?
    undone += 1 if self.social_networks.empty?
    undone += 1 if self.experiences.empty?
    undone += 1 if self.educations.empty?

    done = total - undone
    (done/total*100).round
  end

  def email_confirmation
    @email_confirmation || self.email
  end

  def create_settings!
    self.settings = TourSetting.create(view_mural: Privacy[:friends])
  end

  #FIXME falta testar alguns casos
  def age
    dob = self.birthday
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # Retrieves five contacts recommendations
  def recommended_contacts(quantity)
    if self.friends_count == 0
      contacts_and_pending_ids = User.contacts_and_pending_contacts_ids.
        where("friendships.user_id = ?", self.id)
      # Populares da rede exceto o próprio usuário e os usuários que ele,
      # requisitou/foi requisitada a amizade.
      users = User.select('id, login, avatar_file_name, friends_count, first_name, last_name, avatar_updated_at').
                          without_ids(contacts_and_pending_ids << self).
                          popular(20) |
      # Professores populares da rede exceto o próprio usuário e os usuários,
      # que ele requisitou/foi requisitada a amizade.
        User.select('id, login, avatar_file_name, friends_count, first_name, last_name, avatar_updated_at').
                    without_ids(contacts_and_pending_ids << self).
                    popular_teachers(20) |
      # Usuários com o mesmo domínio de email exceto o próprio usuário e os,
      # usuários que ele requisitou/foi requisitada a amizade.
        User.select('id, login, avatar_file_name, friends_count, first_name, last_name, avatar_updated_at').
                    without_ids(contacts_and_pending_ids << self).
                    with_email_domain_like(self.email).limit(20)
    else
      # Colegas de curso e amigos de amigos
      users = colleagues(20) | self.friends_of_friends
    end

    # Choosing randomly
    if quantity >= (users.length - 1)
      quantity = (users.length - 1)
    end
    (1..quantity).collect do
      users.delete_at(SecureRandom.random_number(users.length - 1))
    end
  end

  # Participam do mesmo curso, mas não são contatos nem possuem requisição
  # de contato pendente.
  def colleagues(quantity)
    contacts_ids = User.contacts_and_pending_contacts_ids.
      where("friendships.user_id = ?", self.id)
    User.select("DISTINCT users.id, users.login, users.avatar_file_name," \
                " users.first_name, users.last_name, users.avatar_updated_at").
      joins("LEFT OUTER JOIN course_enrollments ON" \
            " course_enrollments.user_id = users.id AND" \
            " course_enrollments.type = 'UserCourseAssociation'").
      where("course_enrollments.state = 'approved' AND" \
            " course_enrollments.user_id NOT IN (?, ?)",
            contacts_ids, self.id).
      limit(quantity)
  end

  def friends_of_friends
    contacts_ids = self.friends.select("users.id")
    contacts_and_pending_ids = User.contacts_and_pending_contacts_ids.
      where("friendships.user_id = ?", self.id)
    User.select("DISTINCT users.id, users.login, users.avatar_file_name," \
                " users.first_name, users.last_name, users.avatar_updated_at").
      joins("LEFT OUTER JOIN `friendships`" \
            " ON `friendships`.`friend_id` = `users`.`id`").
      where("friendships.status = 'accepted' AND friendships.user_id IN (?)" \
            " AND friendships.friend_id NOT IN (?, ?)",
            contacts_ids, contacts_and_pending_ids, self.id)
  end

  def most_important_education
    educations = []
    edu = self.educations

    educations << edu.select { |e| e.educationable_type == 'HigherEducation' }.first
    educations << edu.select { |e| e.educationable_type == 'ComplementaryCourse' }.first
    educations << edu.select { |e| e.educationable_type == 'HighSchool' }.first

    educations.compact!
    educations
  end

  def subjects_id
    self.lectures.collect{ |lecture| lecture.subject_id }
  end

  def has_no_visible_profile_information
    self.experiences.actual_jobs.empty? && self.educations.empty? &&
    self.birthday.nil? && self.languages.blank? &&
    self.birth_localization.blank? && self.localization.blank?
  end

  def generate_recovery_token
    self.recovery_token = SecureRandom.urlsafe_base64(nil,false)
    if self.save
      UserNotifier.delay(:queue => 'email', :priority => 1).
        user_reseted_password(self)
    end
  end

  def user_channel
    self.channel || generate_channel
  end



  protected

  def generate_channel
    channel =  SecureRandom.hex(20)
    users = User.where(channel: channel)
    while !users.empty?
      channel =  SecureRandom.hex(20)
      users = User.where(channel: channel)
    end
    update_attribute(:channel, channel)
    channel
  end

  def enable_humanizer
    Rails.application.config.enable_humanizer
  end

  def activate_before_save
    self.activated_at = Time.now.utc
    self.activation_code = nil
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # before filters
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    new_password = ""
    1.upto(len) { |i| new_password << chars[rand(chars.size-1)] }
    return new_password
  end

  #Metodo que remove os espaços em branco no incio e no fim desses campos
  def strip_whitespace
    %w(login first_name last_name email).each do |var|
      self.send("#{var}=", (self.send(var).strip if attribute_present? var))
    end
  end

  private

  def email_has_valid_domain
    return unless required_user_email_domain
    return if errors[:email].any?
    return if email.ends_with?("@#{required_user_email_domain}")

    errors.add(:email, invalid_email_domain_error_message)
  end

  def required_user_email_domain
    @required_user_email_domain ||= ENV[REQUIRED_USER_EMAIL_DOMAIN_ENVAR]
  end

  def invalid_email_domain_error_message
    "E-mail precisa terminar com @#{required_user_email_domain}."
  end
end
