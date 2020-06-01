# -*- encoding : utf-8 -*-
class LecturesController < BaseController
  require 'viewable'
  LIVREDOC_URL = ENV['LIVREDOC_IP']

  respond_to :html, :js

  before_filter :find_subject_space_course_environment, except: [:getpdf]

  include Viewable # atualiza o view_count
  load_and_authorize_resource :subject, except: [:getpdf]
  load_and_authorize_resource :lecture,
    :except => [:new, :create, :cancel, :getpdf],
    :through => :subject

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.fullpath

    respond_to do |format|
      format.html do
       space = Space.find(params[:space_id])
       redirect_to preview_environment_course_path(space.course.environment,
                                                   space.course)
      end
      format.js { render :js => "alert('Você não possui espaço suficiente.')" }
    end
  end

  def rate
    @lecture.rate(params[:stars], current_user)

    respond_to do |format|
      format.js
    end

  end

  def getpdf
    lecture = Lecture.find(params[:document_id])
    document = lecture.lectureable
    authorize!(:read, lecture)
    if document.attachment_content_type != 'application/pdf'
      begin
        send_data RestClient.get(
          "#{LIVREDOC_URL}/api/v1/documents/#{document.livredoc_id}",
          livredoc_header
        )
      rescue RestClient::RequestFailed
        pdf_path = File.join(Rails.root, "public")
        send_pdf(pdf_path+'/error_pdf.pdf')
      end
    else
      send_pdf(document.attachment.path)
    end
  end

  def index
    redirect_to space_subject_path(@subject.space, @subject)
  end

  # GET /lectures/1
  # GET /lectures/1.xml
  def show
    update_view_count(@lecture)

    @status = Status.new
    @statuses = @lecture.activities.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    @can_manage_lecture = can?(:manage, @lecture)

    if enrollment = current_user.get_association_with(@lecture.subject)
      asset_report = @lecture.asset_reports.of_user(current_user).first
      @student_grade = enrollment.grade.to_i
      @done = asset_report.try(:done)
    end

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
        format.html do
          render :show_page
        end
      elsif @lecture.lectureable_type == 'Seminar'
        format.html do
          render :show_seminar
        end
      elsif @lecture.lectureable_type == 'Document'
        format.html do
          render :show_document
        end
      elsif @lecture.lectureable_type == 'Api::Canvas'
        format.html do
          options = { :redu_space_id => @space.id, :redu_subject_id => @subject.id,
                      :redu_lecture_id => @lecture_id, :redu_container => :lecture,
                      :redu_user_id => current_user.id }
          @canvas_url = @lecture.lectureable.current_url(options)

          render :show_canvas
        end
      elsif @lecture.lectureable_type == 'Exercise'
        format.html do
          @result = @lecture.lectureable.result_for(current_user)
          @first_question = @lecture.lectureable.questions.
            first(:conditions => { :position => 1 })
          render :show_exercise
        end
      end
      format.js do
        render_endless 'statuses/item', @statuses, '#statuses',
          template: 'shared/new_endless_kaminari'
      end
      format.html
      format.xml  { render :xml => @lecture }
    end

  end

  # GET /lectures/new
  # GET /lectures/new.xml
  def new
    @lecture = Lecture.new
    lectureable_params = { :_type => params.fetch(:type, 'Page') }
    @lecture.build_lectureable(lectureable_params)

    if @lecture.lectureable.is_a? Exercise
      @lecture.lectureable.build_question_and_alternative
    end

    respond_with(@space, @subject, @lecture) do |format|
      format.js { render "lectures/admin/new" }
    end
  end

  # GET /lectures/1/edit
  def edit
    @page = @lecture.lectureable
    respond_with(@space, @subject, @lecture)
  end

  # POST /lectures
  # POST /lectures.xml
  def create
    if params[:lecture_id] # Existent
      @lecture = Lecture.find(params[:lecture_id])
      @lecture = @lecture.clone_for_subject!(params[:subject_id])
    else # Nova lecture
      @lecture = Lecture.new(params[:lecture])
      @lecture.owner = current_user
      @lecture.subject = Subject.find(params[:subject_id])

      if @lecture.valid? && @lecture.make_sense?
        lectureable = @lecture.lectureable
        if lectureable.is_a? Seminar
          authorize! :upload_multimedia, @lecture
          @lecture.save
          lectureable.convert! if lectureable.need_transcoding?
        elsif lectureable.is_a? Document
          authorize! :upload_document, @lecture
          @lecture.save
          if @lecture.lectureable.attachment_content_type != 'application/pdf'
            response = nil
            begin
              response = RestClient.post(
                "#{LIVREDOC_URL}/api/v1/documents",
                {
                  :document_id => @lecture.lectureable.id,
                  :file => File.new(@lecture.lectureable.attachment.path)
                },
                livredoc_header
              )
              response = JSON.parse(response)
              @lecture.lectureable.livredoc_id = response['id']
            rescue RestClient::RequestFailed
              @lecture.lectureable.livredoc_id = nil
            end
            @lecture.save
          end
        else
          @lecture.save
        end

        @space.course.quota.try(:refresh!)
        @space.course.environment.quota.try(:refresh!)
      else
        if @lecture.lectureable.is_a? Exercise
          @lecture.lectureable.build_question_and_alternative
        end
      end
    end

    @lecture.create_asset_report if @lecture.finalized?

    @quota = @course.quota || @course.environment.quota
    @plan = @course.plan || @course.environment.plan

    respond_to do |format|
      format.js { render "lectures/admin/create" }
    end
  end

  # PUT /lectures/1
  # PUT /lectures/1.xml
  def update
    @lecture = Lecture.find(params[:id])
    params[:lecture][:lectureable_attributes].delete(:_type)
    @lecture.attributes = params[:lecture]

    # Reload necesário pois o form_for estava sendo gerado c/ a alternativa
    # removida sem atualicação de refs https://github.com/redu/redu/issues/505
    if @lecture.lectureable.is_a?(Exercise)
      authorize!(:manage, @lecture.lectureable)
      @lecture.save && @lecture.reload if @lecture.lectureable.make_sense?
      if @lecture.lectureable.is_a? Exercise
        @lecture.lectureable.build_question_and_alternative
      end
    else
      @lecture.save
    end

    respond_to do |format|
      format.js { render 'lectures/admin/update' }
    end
  end

  # DELETE /lectures/1
  # DELETE /lectures/1.xml
  def destroy
    @lecture.destroy
    @lecture.subject.space.course.quota.try(:refresh!)
    @lecture.subject.space.course.environment.quota.try(:refresh!)
    @lecture.refresh_students_profiles

    @quota = @course.quota || @course.environment.quota
    @plan = @course.plan || @course.environment.plan

   respond_with(@space, @subject, @lecture) do |format|
     format.js { render "lectures/admin/destroy" }
      format.html do
        flash[:notice] = "A aula foi removida."
        redirect_to space_subject_path(@space, @subject)
      end
    end
  end

  # Marca a aula como done para um dado usuário
  def done
    if params[:done] == '0'
      @done = 0
    elsif params[:done] == '1'
      @done = 1
    end
    @lecture.mark_as_done_for!(current_user, @done)

    student_profile = current_user.enrollments.
      where(:subject_id => @subject).last
    student_profile.update_grade!
    @student_grade = student_profile.reload.grade.to_i

   respond_to do |format|
     format.js
     format.html { redirect_to space_subject_lecture_path(@subject.space,
                                                          @subject,
                                                          @lecture) }
   end
  end

  def page_content
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  protected

  def send_pdf(path)
    file = path
    File.open(file, 'r') do |f|
      send_data f.read.force_encoding('BINARY')
    end
  end

  def find_subject_space_course_environment
    if @lecture
      @subject = @lecture.subject
    else
      @subject = Subject.find(params[:subject_id])
    end

    @space = @subject.space
    @course = @space.course
    @environment = @course.environment
  end

  def livredoc_header
    {:Authorization => "Token #{ENV['LIVREDOC_TOKEN']}"}
  end
end
