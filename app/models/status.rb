# -*- encoding : utf-8 -*-
class Status < ActiveRecord::Base
  belongs_to :statusable, :polymorphic => true
  belongs_to :logeable, :polymorphic => true
  belongs_to :user
  has_many :answers, :as => :in_response_to,
    :dependent => :delete_all,
    :order => "created_at ASC",
    :include => [:user]
  has_many :users, :through => :status_user_associations
  has_many :status_user_associations, :dependent => :delete_all
  has_many :status_resources, :dependent => :delete_all

  accepts_nested_attributes_for :status_resources
  validates_associated :status_resources
  validates :type, :inclusion => {
    :in => %w(Status Activity Help Answer Log CompoundLog)
  }

  scope :activity_by_user, lambda { |u|
    where("type = ? AND user_id = ?", "Activity", u) }
  scope :helps_and_activities, where("type = ? OR type = ?", "Help", "Activity")
  scope :by_statusable, lambda { |kind, id| where("statusable_id IN (?) AND statusable_type = ?", id, kind.to_s) }
  scope :by_day, lambda { |day| where(:created_at =>(day..(day+1))) }
  scope :by_id, lambda { |id| where(:id =>id) }
  scope :not_compound_log, where("statuses.type NOT LIKE ?", "CompoundLog")
  scope :recent, lambda { where("created_at > ?", 1.week.ago) }

  # Retorna apenas status visíveis
  scope :visible, where(:compound => false)

  class << self
    def find_and_include_related(*args)
      included = { include: \
                   [{ answers: [:user, :status_resources] }, :status_resources]}

      options = included.merge(args.extract_options!)
      find(args.first, options)
    end
  end

  # Associa self à lista de usuários
  def associate_with(users)
    users.includes(:status_user_associations).each do |u|
      u.status_user_associations.create(:status => self)
    end
  end

  def self.associate_with(status, users)
    ids = \
      users.is_a?(ActiveRecord::Relation) ? users.value_of(:id) : users.map(&:id)

    columns = [:user_id, :status_id]
    options = { :validate => false, :on_duplicate_key_update => [:user_id] }
    values = ids.map { |user_id| [user_id, status.id] }

    StatusUserAssociation.import(columns, values, options)
  end

  def answers_ids(id)
    answers.where("user_id = ?", id).collect{ |answer| answer.id }
  end
end
