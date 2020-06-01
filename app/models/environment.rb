# -*- encoding : utf-8 -*-
class Environment < ActiveRecord::Base
  include ActsAsBillable
  include DestroySoon::ModelAdditions
  include EnvironmentSearchable

  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  after_create :create_environment_association
  after_create :create_course_association, :unless => "self.courses.empty?"
  
  has_many :courses, :dependent => :destroy,
    :conditions => ["courses.destroy_soon = ?", false]
  has_many :all_courses, :dependent => :destroy, :class_name => "Course"
  has_many :user_environment_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  has_many :users, :through => :user_environment_associations
  # environment_admins
  has_many :administrators, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", :environment_Admin ]
  # teachers
  has_many :teachers, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", :teacher ]
  # tutors
  has_many :tutors, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", :tutor ]

  # students (role member)
  has_many :students, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", :member ]

  has_one :quota, :dependent => :destroy, :as => :billable

  attr_protected :owner, :published

  acts_as_taggable
  has_attached_file :avatar, Redu::Application.config.paperclip_environment

  validates_presence_of :name, :path, :initials
  validates_uniqueness_of :name, :path
  validates_length_of :name, :maximum => 40
  validates_length_of :path, :maximum => 100
  validates_length_of :description, :maximum => 400, :allow_blank => true
  validates_length_of :initials, :maximum => 10
  validates_format_of :path, :with => /^[-_A-Za-z0-9]*$/

  accepts_nested_attributes_for :courses

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(args)
    else
      super
    end
  end

  def to_param
    return self.id.to_s if self.path.empty?
    self.path
  end

  # Muda o papel do usuário levando em conta a hierarquia
  def change_role(user, role)
    membership =
      self.user_environment_associations.where(:user_id => user.id).first
    membership.update_attributes({:role => role})

    user.user_course_associations.where(:course_id => self.courses).
      each do |membership|
        membership.course.change_role(user, role)
      end
  end

  # Retorna as iniciais ou, se não houver, o nome
  def initials_or_name
    (self.initials.nil? or self.initials.empty?) ? self.name : self.initials
  end

  # Indica se o plano suporta a entrada de mais um usuário no ambiente
  def can_add_entry?
    self.users.count < self.plan.members_limit
  end

  # Remove os usuários do ambiente
  def remove_users(users)
    users.each do |user|
      (user.courses & self.courses).each do |c|
        c.unjoin user
      end
    end
  end

  protected

  def create_environment_association
    UserEnvironmentAssociation.create(:environment => self,
                                      :user => self.owner,
                                      :role => Role[:environment_admin])
  end

  def create_course_association
    course_assoc = UserCourseAssociation.create(
      :course => self.courses.first,
      :user => self.owner,
      :role => Role[:environment_admin])
      course_assoc.approve!
  end
end
