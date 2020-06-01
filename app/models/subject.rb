# -*- encoding : utf-8 -*-
class Subject < ActiveRecord::Base
  include EnrollmentService::BaseModelAdditions
  include EnrollmentService::SubjectAdditions::ModelAdditions

  belongs_to :space
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
  has_many :lectures, :order => "position", :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :members, :through => :enrollments, :source => :user
  has_many :graduated_members, :through => :enrollments, :source => :user,
    :conditions => ["enrollments.graduated = 1"]
  has_many :teachers, :through => :enrollments, :source => :user,
    :conditions => ["enrollments.role = ?", :teacher]
  has_many :statuses, :as => :statusable, :order => "created_at DESC"
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy
  has_many :asset_reports

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :visible, lambda { where('visible = ?', true) }

  attr_protected :owner, :finalized, :user_id

  validates_presence_of :name

  def change_lectures_order!(ids_order)
    ids_order.each_with_index do |id, i|
      unless !Lecture.exists?(id)
        lecture = Lecture.find(id)
        lecture.position = i + 1 # Para não ficar índice zero.
        lecture.save
      end
    end
  end

  def recent?
    self.created_at > 1.week.ago
  end

  def graduated?(user)
    self.enrolled?(user) && user.get_association_with(self).graduated?
  end

  # Verifica se o módulo está pronto para ser publicado via
  # visão geral ou e-mail
  def notificable?
    self.finalized && self.visible && !self.logs.exists?
  end

  # Notifica todos alunos matriculados sobre a adição de Subject
  def notify_subject_added
    if notificable?
      self.space.users.all.each do|u|
        UserNotifier.delay(:queue => 'email').subject_added(u, self)
      end
    end
  end

  def self.destroy_subjects_unfinalized
    Subject.where(['created_at < ? AND finalized = 0', 1.day.ago]).each do |s|
      s.destroy
    end
  end
end
