# -*- encoding : utf-8 -*-
class Course < ActiveRecord::Base
  include ActsAsBillable
  include DestroySoon::ModelAdditions
  include CourseSearchable
  include StatusService::BaseModelAdditions
  include StatusService::StatusableAdditions::ModelAdditions

  # Apenas deve ser chamado na criação do segundo curso em diante
  after_create :create_user_course_association, :unless => "self.environment.nil?"

  belongs_to :environment
  has_many :spaces, :dependent => :destroy,
    :conditions => ["spaces.destroy_soon = ?", false]
  has_many :all_spaces, :dependent => :destroy, :class_name => "Space"
  has_many :user_course_associations, :dependent => :destroy
  has_many :user_course_invitations, :dependent => :destroy
  has_many :course_enrollments
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  has_many :users, :through => :user_course_associations
  has_many :approved_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "course_enrollments.state = ?",
                                       'approved' ]
  has_many :pending_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "course_enrollments.state = ?",
                                       'waiting' ]
  # environment_admins
  has_many :administrators, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "course_enrollments.role = ? AND course_enrollments.state = ?",
                      :environment_admin, 'approved' ]
  # teachers
  has_many :teachers, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "course_enrollments.role = ? AND course_enrollments.state = ?",
                      :teacher, 'approved' ]
  # tutors
  has_many :tutors, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "course_enrollments.role = ? AND course_enrollments.state = ?",
                      :tutor, 'approved' ]
  # students (member)
  has_many :students, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "course_enrollments.role = ? AND course_enrollments.state = ?",
                      :member, 'approved' ]

  # new members (form 1 week ago)
  has_many :new_members, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "course_enrollments.state = ? AND course_enrollments.updated_at >= ?", 'approved', 1.week.ago]

  has_many :teachers_and_tutors, :through => :user_course_associations,
    :source => :user, :select => 'users.id',
    :conditions => [ "(course_enrollments.role = ? OR course_enrollments.role = ?) AND course_enrollments.state = ?", :teacher, :tutor, 'approved']

  has_and_belongs_to_many :audiences

  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy

  scope :published, where(:published => 1)
  scope :of_environment, lambda { |environmnent_id|
    where(:environment_id => environmnent_id)
  }

  scope :with_audiences, lambda { |audiences_ids|
    joins(:audiences).where('audiences_courses.audience_id IN (?)',
                             audiences_ids).group('courses.id')
  }

  scope :user_behave_as_administrator, lambda { |user_id|
    joins(:user_course_associations).
      where("course_enrollments.user_id = ? AND course_enrollments.role = ?",
             user_id, :environment_admin)
  }

  scope :user_behave_as_teacher, lambda { |user_id|
    joins(:user_course_associations).
      where("course_enrollments.user_id = ? AND course_enrollments.role = ?",
              user_id, :teacher)
  }

  scope :user_behave_as_tutor, lambda { |user_id|
    joins(:user_course_associations).
      where("course_enrollments.user_id = ? AND course_enrollments.role = ?",
              user_id, :tutor)
  }

  scope :user_behave_as_student, lambda { |user_id|
    joins(:user_course_associations).
      where("course_enrollments.user_id = ? AND course_enrollments.role = ? AND course_enrollments.state = ?",
              user_id, :member, 'approved')
  }

  attr_protected :owner, :published, :environment

  acts_as_taggable

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :path, :scope => :environment_id
  validates_length_of :name, :maximum => 60
  validates_length_of :path, :maximum => 100
  validates_length_of :description, :maximum => 250, :allow_blank => true
  validates_format_of :path, :with => /^[-_A-Za-z0-9]*$/


  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(*args)
    else
      super
    end
  end

  def to_param
    return self.id.to_s if self.path.empty?
    self.path
  end

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = user.user_course_associations.
                   where(:course_id => self.id).first
    membership.update_attributes({:role => role})

    user.user_space_associations.where(:space_id => self.spaces).
      includes(:space).each do |usa|
        usa.space.change_role(user, role)
      end
  end

  def create_user_course_association
    self.environment.administrators.each do |env_admin|
      user_course =
        UserCourseAssociation.create(:user => env_admin,
                                     :course => self,
                                     :role => Role[:environment_admin])
      user_course.approve!
    end
  end

  # Associa um usuário com um curso
  # se o curso for aberto, ele é aprovado
  # automaticamente. Caso contrário o usuário
  # só é aceito se possuir um convite para este
  # curso.
  def join(user, role = Role[:member])
    association = UserCourseAssociation.create(:user_id => user.id,
                                               :course_id => self.id,
                                               :role => role)

    association = user.get_association_with(self) if association.new_record?

    if self.subscription_type.eql? 1 and association.waiting?  # Todos podem participar, sem moderação
      association.approve!
    elsif association.invited?
      association.accept!
    end
  end

  # Associa um usuário com um curso,
  # nesse caso o usuário sempre será
  # aceito/aprovado no curso
  def join!(user, role  = Role[:member])
    association = UserCourseAssociation.create(:user_id => user.id,
                                               :course_id => self.id,
                                               :role => role)
    association = user.get_association_with(self) if association.new_record?
    if association.waiting?
      association.approve!
    elsif association.invited?
      association.accept!
    end
  end

  # Desassocia o usuário do curso

  # - Remove a associação do usuário com o Course
  # - Remove a associação do usuário com o Environment, caso ele passe a não
  #   fazer parte de nenhum Course
  # - Remove as associações com os Spaces
  # - Remove as associações com os Subjects
  # - Notifica Vis em relação a remoção dos enrollments
  #
  # * Pode ser chamado mesmo se o usuário estiver sob moderação
  def unjoin(user)
    course_association = user.get_association_with(self)
    course_association.try(:destroy)


    # Desassocia o usuário do ambiente se ele não participar de outros cursos
    # Reload necessário devido cache do BD
    unless (user.courses.reload & self.environment.courses).count > 0
      user.get_association_with(self.environment).try(:destroy)
    end

    self.spaces.each do |space|
      space_association = user.get_association_with(space)
      space_association.try(:destroy)
    end

    subjects = Subject.where(:space_id => self.spaces)
    Subject.unenroll(subjects, user)
  end


  def notify(compound_log)
    Status.associate_with(compound_log, self.approved_users.select('users.id'))
  end

  def create_hierarchy_associations(user, role = Role[:member])
    enrollments = []
    # FIXME mudar estado do user_course_association para approved
    # Cria as associações no Environment do Course e em todos os seus Spaces.
    UserEnvironmentAssociation.create(:user_id => user.id,
                                      :environment_id => self.environment.id,
                                      :role => role)
    usas = self.spaces.collect do |space|
      UserSpaceAssociation.new(:user_id => user.id, :space_id => space.id,
                               :role => role)
    end
    UserSpaceAssociation.import(usas, :validate => false)

    subjects = self.spaces.includes(:subjects).collect(&:subjects).flatten
    enrollments = Subject.enroll(subjects, :users => [user], :role => role)
  end

  # Verifica se o usuário em questão está esperando aprovação num determinado
  # Course
  def waiting_approval?(user)
    assoc = user.get_association_with self
    return false if assoc.nil?
    assoc.waiting?
  end

  # Verifica se o usuário em questão teve a sua participação rejeitada em um
  # determinado Course
  def rejected_participation?(user)
    assoc = user.get_association_with self
    return false if assoc.nil?
    assoc.rejected?
  end

  # Verifica se o usuário em questão foi convidade para um determinado
  # Course, mas ainda não aceitou o convite
  def waiting_user_approval?(user)
    assoc = user.get_association_with self
    return false if assoc.nil?
    assoc.invited?
  end

  # Método de alto nível que convida um determinado usuário para o curso.
  # - Caso o usuário não faça parte do curso uma UCA será criada com o estado
  #   invited.
  # - Caso o usuário já faça parte do curso, nada irá acontecer
  # - Caso o usuário esteja na lista de moderação, seu estado será mudado para
  #   invited
  # - Caso o usuário já tenha sido convidado e não tenha aceito o convite, um
  #   novo e-mail será enviado.
  def invite(user)
    assoc = self.user_course_associations.create(:user => user,
                                                 :role => Role[:member],
                                                 :state => "waiting")
    if assoc.new_record?
      assoc = user.get_association_with(self)
      # Se já foi convidado, apenas reenvia o e-mail
      if assoc.invited?
        assoc.send_course_invitation_notification
        assoc.updated_at = Time.now
        assoc.save
      elsif assoc.waiting?
        assoc.approve!
      end
    else
      assoc.invite!
    end

    assoc
  end

  # Método de alto nível que convida um determinado usuário para o curso
  # através do e-mail.
  # - Caso o e-mail já tenha sido convidado e não tenha aceito o convite, um
  #   novo e-mail será enviado.
  def invite_by_email(email)
    u =  User.find_by_email(email)
    if u
      invitation = self.invite(u)
    else
      invitation = self.user_course_invitations.create(:email => email)
      # Se já foi convidado, apenas reenvia o e-mail
      if invitation.new_record?
        invitation = self.user_course_invitations.with_email(email).first
        # Caso o e-mail seja mal-formado, não vai salvar e será ignorado.
        unless invitation.nil?
          invitation.send_external_user_course_invitation
          invitation.updated_at = Time.now
          invitation.save
        end
      else
        invitation.invite!
      end
    end
    invitation
  end

  # Indica se o curso possui convites para usuários não registrados
  def invited?(email)
    self.user_course_invitations.find_by_email(email)
  end

  # Indica se o plano suporta a entrada de mais um usuário no curso
  def can_add_entry?
    if self.plan
      self.approved_users.count < self.plan.members_limit
    else
      self.environment.can_add_entry?
    end
  end

end
