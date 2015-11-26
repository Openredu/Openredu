# -*- encoding : utf-8 -*-
class EnvironmentsController < BaseController
  load_and_authorize_resource :except => :index, :find_by => :path

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.fullpath

    if @environment
      if @environment.blocked?
        flash[:error] = "Entre em contato com o administrador deste ambiente."
      elsif current_user.nil?
        flash[:info] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
      else
        flash[:info] = "Você não tem acesso a essa página"
      end

      redirect_to preview_environment_path(@environment)
    else
      flash[:error] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
      redirect_to application_path
    end
  end

  # GET /environments/1
  # GET /environments/1.xml
  def show
    @courses = @environment.courses.includes(:environment, :tags)

    unless can? :manage, @environment
      @courses = @courses.published
    end

    @courses = @courses.order('name ASC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html
      format.js { render_endless 'courses/item', @courses,
                  '#courses_list' }
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/new
  # GET /environments/new.xml
  def new
    respond_to do |format|
      format.html
      format.xml { render :xml => @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    respond_to do |format|
      format.html { render 'environments/admin/edit' }
    end
  end

  # POST /environments
  # POST /environments.xml
  def create
    case params[:step]
    when "1" # tela dos forms
      @step = 2

      respond_to do |format|
        format.html { render :new }
      end
    when "2" # tela de informações
      respond_to do |format|
        if @environment.valid?
          @step = 3

          format.html { render :new }
        else
          @step = 2

          format.html { render :new }
        end
      end
    when "3"

      respond_to do |format|
        @environment.owner = current_user
        @environment.courses.first.owner = current_user

        if @environment.save
          @environment.courses.first.create_quota
        format.html do
          flash[:notice] = "Parabens, o seu ambiente de ensino foi criado"
        end
        format.js do
          render :redirect
        end
        else
          format.js { render :new }
          format.html { render :new }
          format.xml  { render :xml => @environment.errors,
            :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /environments/1
  # PUT /environments/1.xml
  def update
    @header_environment = @environment.clone

    respond_to do |format|
      if @environment.update_attributes(params[:environment])
        flash[:notice] = 'Ambiente atualizado com sucesso.'
        format.html { redirect_to(@environment) }
        format.xml  { head :ok }
      else
        format.html { render 'environments/admin/edit' }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.xml
  def destroy
    @environment.audit_billable_and_destroy

    respond_to do |format|
      format.html { redirect_to(teach_index_url) }
      format.xml  { head :ok }
    end
  end

  # Visão do Environment para usuários não-membros.
  # TODO Remover quando colocar as permissões, apenas redirecionar no show.
  def preview
    if (can? :read, @environment) && (!can? :manage, @environment)
      redirect_to environment_path(@environment) and return
    end

    @courses = @environment.courses.includes(:user_course_associations).
      includes(:spaces).published.order('name ASC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html
      format.js { render_endless 'courses/item', @courses, '#courses_list' }
      format.xml  { render :xml => @environment }
    end
  end

  def admin_courses
    @courses = @environment.courses.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render "environments/admin/admin_courses" }
      format.js do
        render_endless 'courses/admin/item_admin', @courses, '#course_list'
      end
    end
  end

  def admin_members
    @memberships = @environment.user_environment_associations.includes(:user).
      order('updated_at DESC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render "environments/admin/admin_members" }
      format.js do
        render_endless 'environments/admin/user_item_admin', @memberships,
          '#user_list_table'
      end
    end
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      users = User.with_ids(users_ids).includes(:user_course_associations)
      @environment.remove_users(users)

      flash[:notice] = "Os usuários foram removidos do ambiente #{@environment.name}"
    end

    respond_to do |format|
      format.html { redirect_to :action => :admin_members }
    end
  end

  def search_users_admin
    roles = []
    roles = params[:role_filter].collect {|r| r.to_s} if params[:role_filter]
    keyword = []
    keyword = params[:search_user] || nil

    @memberships = UserEnvironmentAssociation.with_roles(roles).
                   of_environment(@environment).with_keyword(keyword).
                   includes(:user => [{ :user_course_associations => :course }]).
                   order('user_environment_associations.updated_at DESC').
                   page(params[:page]).per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.js { render "environments/admin/search_users_admin" }
    end
  end

  def index
    if params.has_key?(:user_id)
      @user = User.find(params[:user_id])
      view_path = 'users/environments/index'
    else
      @user = current_user
      view_path = 'environments/index'
    end

    authorize! :manage, @user

    @total_environments = @user.environments.count
    @environments = @user.environments.
      includes(:courses => :spaces).page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html do
        render view_path, :layout => 'new_application'
      end
      format.js do
        render_endless('users/environments/environment', @environments,
                       '#my-environments',
                       { :template => 'shared/new_endless_kaminari',
                         :partial_locals => { :user => @user } })
      end
    end
  end
end
