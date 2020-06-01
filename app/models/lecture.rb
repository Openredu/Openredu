# -*- encoding : utf-8 -*-
class Lecture < ActiveRecord::Base
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.
  include SimpleActsAsList::ModelAdditions
  include EnrollmentService::LectureAdditions::ModelAdditions
  include StatusService::BaseModelAdditions
  include StatusService::StatusableAdditions::ModelAdditions

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  has_many :asset_reports, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "user_id"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :subject

  accepts_nested_attributes_for :lectureable

  # SCOPES
  scope :seminars, where("lectureable_type LIKE 'Seminar'")
  scope :iclasses, where("lectureable_type LIKE 'InteractiveClass'")
  scope :pages, where("lectureable_type LIKE 'Page'")
  scope :documents, where("lectureable_type LIKE 'Document'")
  scope :exercises, where("lectureable_type LIKE 'Exercise'")
  scope :exercises_editables, where("lectureable_type LIKE 'Exercise' and lectureable_id NOT IN (SELECT exercise_id FROM results)")
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :by_subjects, lambda { |subjects_id| where(:subject_id =>subjects_id) }
  scope :by_day, lambda { |day| where(:created_at =>(day..(day+1))) }

  attr_protected :owner, :view_count, :is_clone

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  simple_acts_as_list :scope => :subject_id

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :lectureable
  validates_associated :lectureable #FIXME Não foi testado, pois vai ter accepts_nested

  # Friendly url
  def to_param
    "#{id}-#{name.parameterize}"
  end

  # Marca a lecture atual como done ou undone
  def mark_as_done_for!(user, done)
    asset_report = self.asset_reports.of_user(user).last
    asset_report.done = done
    asset_report.save
  end

  def done?(user)
    assets = asset_reports.of_user(user)
    return false if assets.length == 0
    assets.last.done?
  end

  def clone_for_subject!(subject_id)
    if self.lectureable.is_a?(Exercise)
      nested_attrs = { :questions => :alternatives }
    end

    clone = self.dup :include => { :lectureable => nested_attrs },
      :except => [:rating_average, :view_count, :position, :subject_id]

    if self.lectureable.is_a?(Seminar)
      if self.lectureable.external?
        clone.lectureable.external_resource_url = \
          self.lectureable.external_resource_url
      end
    end

    clone.is_clone = true
    clone.subject = Subject.find(subject_id)
    clone.save
    clone
  end

  def refresh_students_profiles
    self.subject.enrollments.each(&:"update_grade!")
  end

  def recent?
    self.created_at > 1.week.ago
  end

  # Diz se a instância está pronta para ser divulgada via mural ou e-mail
  def notificable?
    self.subject.finalized && self.subject.visible
  end

  def build_lectureable(params, options={})
    return if params[:_type].blank?
    begin
      klass = params.delete(:_type).constantize
      if klass == 'Page'.constantize
        params.each_key do |key|
          params = params[key] if params[key].key? 'body'
        end
      elsif klass == 'Exercise'.constantize
        unless params.empty?
          questions_attributes = params['questions_attributes']
          new_params = questions_attributes.deep_dup
          questions_attributes.each do |qa_key,qa_value|
            qa_value.each do |q_key, q_value|
              new_params[qa_key].merge!(new_params[qa_key].delete(q_key)) if q_key =~ /removefromhash_*/
              if q_key == 'alternatives_attributes'
                q_value.each do |as_key, as_value|
                  as_value.each do |a_key, a_value|
                    new_params[qa_key][q_key][as_key].merge!(new_params[qa_key][q_key][as_key].delete(a_key)) if a_key =~ /removefromhash_*/
                  end
                end
              end
            end
          end
          params['questions_attributes'] =  new_params
        end
      end
    rescue NameError # Caso seja não seja um lectureable válido
      return nil
    end
    relation = klass.reflections[:lecture].try(:options)

    if relation && relation[:as] == :lectureable
      self.lectureable = klass.new(params)
    end
  end

  def make_sense?
    if lectureable && lectureable.is_a?(Exercise)
      unless lectureable.make_sense?
        errors.add("lectureable.general", lectureable.errors[:general])
        false
      else
        true
      end
    else
      true
    end
  end

  def finalized?
    self.persisted? && self.subject.finalized?
  end
end
