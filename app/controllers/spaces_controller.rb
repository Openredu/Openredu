# -*- encoding : utf-8 -*-
class SpacesController < BaseController
  include VisApplicationAdditions::Controller

  respond_to :html, :js

  # Necessário pois Space não é nested route de course
  before_filter :find_space_course_environment,
    except: [:cancel]

  load_resource :environment,
    except: [:cancel], find_by: :path
  load_resource :course, through: :environment,
    except: [:cancel], find_by: :path
  load_and_authorize_resource :space, through: :course,
    except: [:cancel]

  Browser = Struct.new(:browser, :version)
  UNSUPPORTED_BROWSERS = [Browser.new("Internet Explorer")]

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.fullpath

    if current_user.nil?
      flash[:info] = "Essa área só pode ser vista após você acessar o #{Redu::Application.config.name} com seu nome e senha."
    else
      flash[:info] = "Você não tem acesso a essa página"
    end

    redirect_to preview_environment_course_path(@environment, @course)
  end

  def admin_members
    @memberships = @space.user_space_associations.includes(:user).
      order('updated_at DESC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render 'spaces/admin/admin_members' }
      format.js do
        render_endless 'spaces/admin/user_item_admin', @memberships,
          '#user_list_table'
      end
    end
  end

  def admin_subjects
    @subjects = @space.subjects

    respond_to do |format|
       format.html { render "spaces/admin/admin_subjects" }
    end
  end

  def mural
    if @space and @space.removed
      redirect_to removed_page_path and return
    end

    if @space
      @statuses = @space.activities.page(params[:page]).
        per(Redu::Application.config.items_per_page)
      @statusable = @space
    end

    respond_to do |format|
      if @space
        @status = Status.new

        format.html
        format.js do
          render_endless 'statuses/item', @statuses, '#statuses',
            template: 'shared/new_endless_kaminari'
        end
        format.xml  { render xml: @space }
      else
        format.html {
          flash[:error] = "A disciplina \"" + params[:id] + "\" não existe ou não está cadastrada no #{Redu::Application.config.name}."
          redirect_to spaces_path
        }
      end
    end
  end

  # GET /spaces/1
  # GET /spaces/1.xml
  def show
    @subjects = @space.subjects.includes([:lectures, :space]).
      order('updated_at ASC')

    unless can? :manage, @space
      @subjects = @subjects.visible
    end

    @subjects = @subjects.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html
      format.js { render_endless 'subjects/item', @subjects, '#subjects_list' }
    end
  end

  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @space = Space.new(params[:space])
    @course = Course.find(params[:course_id])
    @environment = @course.environment

    respond_to do |format|
      format.html { render "spaces/admin/new" }
    end
  end

  # GET /spaces/1/edit
  def edit
    @plan = @space.course.plan || @space.course.environment.plan
    @billable = @plan.billable

    respond_to do |format|
      format.html { render "spaces/admin/edit" }
    end
  end

  # POST /spaces
  # POST /spaces.xml
  def create
    @space = Space.new(params[:space])
    @space.course = @course
    @environment = @course.environment
    @space.owner = current_user

    if @space.valid?
      @space.save
    end

    respond_to do |format|
      if @space.new_record?
        format.html { render template: 'spaces/admin/new' }
      else
        format.html do
          flash[:notice] = "Disciplina criada!"
          redirect_to environment_course_path(@environment, @course)
        end
      end
    end
  end

  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    @plan = @space.course.plan || @space.course.environment.plan
    @billable = @plan.billable
    @header_space = @space.dup
    @header_space.id = @space.id

    respond_to do |format|
      if @space.update_attributes(params[:space])
        flash[:notice] = 'A disciplina foi atualizada com sucesso!'
        format.html { redirect_to(@space) }
        format.xml  { head :ok }
      else
        format.html do
          render 'spaces/admin/edit'
        end
        format.xml  { render xml: @space.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spaces/1
  # DELETE /spaces/1.xml
  def destroy
    @space.async_destroy

    respond_to do |format|
      format.html { redirect_to(environment_course_path(@space.course.environment, @space.course)) }
      format.xml  { head :ok }
    end
  end

  def subject_participation_report
    @browser_not_supported = self.is_browser_unsupported?
    @token = current_vis_token # lib/vis_application_additions...

    respond_to do |format|
      format.html { render "spaces/admin/subject_participation_report" }
    end
  end

  def lecture_participation_report
    @browser_not_supported = self.is_browser_unsupported?
    @token = current_vis_token # lib/vis_application_additions...

    respond_to do |format|
      format.html { render "spaces/admin/lecture_participation_report" }
    end
  end

  def students_participation_report
    @browser_not_supported = self.is_browser_unsupported?
    @token = current_vis_token # lib/vis_application_additions...

    respond_to do |format|
      format.html { render "spaces/admin/students_participation_report" }
    end
  end

  def students_participation_report_show
    @token = current_vis_token # lib/vis_application_additions...

    @start = params[:date_start]
    @end = params[:date_end]

    respond_to do |format|
      format.html { render "spaces/admin/students_participation_show" }
    end
  end

  # Utilizado pelo endless do sidebar
  def students_endless
    respond_to do |format|
      format.js do
        @sidebar_students = @space.students.page(params[:page]).per(4)
        render_sidebar_endless 'users/item_medium_24',
          @sidebar_students, '.connections.students',
          "Mostrando os <X> últimos alunos da disciplina"
      end
    end
  end

  protected

  def find_space_course_environment
    if params.has_key?(:id)
      @space = Space.find(params[:id])
    end
    # No SpaceController#new o course_id é passado como param
    @course = @space.nil? ? Course.find(params[:course_id]) : @space.course
    @environment = @course.environment
  end

  def is_browser_unsupported?
    current_browser = Browser.new(current_user_agent.browser, current_user_agent.version)
    browser = UNSUPPORTED_BROWSERS[0].browser

    if current_browser.browser == browser
      return true
    else
      return false
    end
  end
end
