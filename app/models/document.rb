# -*- encoding : utf-8 -*-
class Document < ActiveRecord::Base
  CONTENT_TYPES = Redu::Application.config.mimetypes['documents'] +
    Redu::Application.config.mimetypes['image']

  has_attached_file :attachment, Redu::Application.config.paperclip_documents
  validates_attachment_content_type :attachment, :content_type => CONTENT_TYPES
  validates_attachment_presence :attachment

  has_one :lecture, :as => :lectureable

  def download_allowed?
     return self.downloadable?
   end

  # Verifica se o curso tem espaço suficiente para o arquivo
  def can_upload_document?(lecture)
    plan = lecture.subject.space.course.plan ||
      lecture.subject.space.course.environment.plan

    return false if plan.state != "active"

    quota = lecture.subject.space.course.quota ||
      lecture.subject.space.course.environment.quota

    if quota.files > plan.file_storage_limit
      return false
    else
      return true
    end
  end

end
