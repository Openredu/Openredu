# -*- encoding : utf-8 -*-
class Seminar < ActiveRecord::Base
  attr_accessor :external_resource_url

  # Lectureable que representa um objeto multimídia simples, podendo ser aúdio,
  # vídeo ou mídia externa (e.g youtube).
  include AASM

  # Video convertido
  has_attached_file :media, Redu::Application.config.video_transcoded
  # Video original. Mantido para caso seja necessário refazer o transcoding
  has_attached_file :original, {}.merge(Redu::Application.config.video_original)

  has_one :lecture, :as => :lectureable

  # Maquina de estados do processo de conversão
  aasm_column :state

  aasm_initial_state :waiting

  aasm_state :waiting
  aasm_state :converting, :enter => :transcode
  aasm_state :converted
  aasm_state :failed

  aasm_event :convert do
    transitions :to => :converting, :from => [:waiting]
  end

  aasm_event :ready do
    transitions :to => :converted, :from => [:waiting, :converting]
  end

  aasm_event :fail do
    transitions :to => :failed, :from => [:converting]
  end

  # Habilita diferentes validações dependendo do tipo
  validates_presence_of :external_resource, :if => :external?
  validates_presence_of :external_resource_type, :if => :external?

  validates_presence_of :original, :unless => :external?
  validates_attachment_presence :original, :unless => :external?
  validate :accepted_content_type, :unless => :external?
  validates_attachment_size :original, :less_than => 1.gigabyte,
    :unless => :external?

  # Converte o video para FLV (Zencoder)
  def transcode
    return
    #Zencoder pega o video e converte, quando termina manda uma requisicao para o antigo endpoint jobs.
    # if Rails.env.development? || Rails.env.test?
    # seminar_info = {
    #   :id => self.id,
    #   :class => self.class.to_s.tableize,
    #   :attachment => 'medias',
    #   :style => 'original',
    #   :basename => self.original_file_name.split('.')[0],
    #   :extension => 'flv'
    # }
    #
    # video_storage = Redu::Application.config.video_transcoded
    # output_path = "s3://" + video_storage[:bucket] + "/" + interpolate(video_storage[:path], seminar_info)
    #
    # credentials = Redu::Application.config.zencoder_credentials
    # config = Redu::Application.config.zencoder
    # config[:input] = self.original.url
    # config[:output][:url] = output_path
    # config[:output][:thumbnails][:base_url] = File.dirname(output_path)
    # config[:output][:notifications][:url] = "http://#{credentials[:username]}:#{credentials[:password]}@www.redu.com.br/jobs/notify"
    #
    # response = Zencoder::Job.create(config)
    # puts response.inspect
    # if response.success?
    #   self.job = response.body["id"]
    # else
    #   self.fail!
    # end
  end

  def video?
    Redu::Application.config.mimetypes['video'].include?(original_content_type)
  end

  def audio?
    Redu::Application.config.mimetypes['audio'].include?(original_content_type)
  end

  def external?
    self.external_resource_type == "youtube"
  end

  # Virtual attribute para url do vídeo
  def external_resource_url
    unless external_resource.nil?
      "https://www.#{ self.external_resource_type }.com/embed/#{ self.external_resource }"
    end
  end

  def external_resource_url=(url)
    capture = url.match(/youtube.com.*(?:\/|v=)([^&$]+)/)

    unless capture.nil?
      self.external_resource_type = "youtube"

      # Pegando texto capturado ou retornando nil se o regex falhar
      capture = capture[1]
      self.external_resource = capture
    end
  end

  def type
    if video?
      self.original_content_type
    else
      self.external_resource_type
    end
  end

  def need_transcoding?
    (self.video? or self.audio?) && self.waiting?
  end

  # Verifica se o curso tem espaço suficiente para o arquivo
  def can_upload_multimedia?(lecture)
    return true if self.external_resource_type == "youtube"

    plan = lecture.subject.space.course.plan ||
      lecture.subject.space.course.environment.plan
    return false unless plan.active?

    quota = lecture.subject.space.course.quota ||
      lecture.subject.space.course.environment.quota
    if quota.multimedia > plan.video_storage_limit
      return false
    else
      return true
    end
  end

  protected
  def interpolate(text, mapping)
    mapping.each do |k,v|
      text = text.gsub(':'.concat(k.to_s), v.to_s)
    end
    return text
  end

  # Workaround: Valida content type setado pelo método define_content_type
  def accepted_content_type
    self.errors.add(:original, "Formato inválido") unless video? or audio?
  end
end
