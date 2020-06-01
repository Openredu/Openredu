# -*- encoding : utf-8 -*-
class UsersController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :except => [:recover_username_password,
    :recover_password, :resend_activation, :activate,
    :confirm_recover_password,
    :index],
    :find_by => :login

  rescue_from CanCan::AccessDenied, :with => :deny_access

  before_filter :remove_errors_field, only: :create

  ## User
  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activated_at
      flash[:notice] = "Sua conta já foi ativada. Utilize seu login e senha para entrar no #{Redu::Application.config.name}."
      redirect_to application_path
      return
    elsif @user and @user.activate
      UserSession.create(@user) if current_user.nil?

      redirect_to home_user_path(@user)
      flash[:notice] = t :thanks_for_activating_your_account
      return
    end
    flash[:error] = t(:account_activation_error)
    redirect_to signup_path
  end

  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t :deactivate_completed
    redirect_to login_path
  end

  def show
    if @user.removed
      redirect_to removed_page_path and return
    end

    @subscribed_courses_count = @user.user_course_associations.approved.count

    respond_to do |format|
      format.html { render layout: 'new_application' }
    end
  end

  def contacts_endless
    # Replicado de users_helper#last_contacts.
    @contacts = if current_user == @user
      @user.friends.page(params[:page]).per(8)
    else
      @user.friends_not_in_common_with(current_user).page(params[:page]).per(4)
    end

    respond_to do |format|
      format.js { render_new_sidebar_endless 'users/item_medium_24_new', @contacts,
        '.connections', "Mostrando os <X> últimos contatos de #{@user.first_name}",
        'connections-endless' }
    end
  end

  def environments_endless
    @environments = @user.environments.page(params[:page]).per(4)

    respond_to do |format|
      format.js { render_new_sidebar_endless 'environments/item_medium',
        @environments, '.profile-enrolled-environments',
        "Mostrando os <X> últimos ambientes de #{@user.first_name}",
        "profile-enrolled-environments-endless", user: @user }
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.create_settings!
      if @key
        @key.user = @user
        @key.save
      end

      # Se tem um token de convite para o curso, aprova o convite para o
      # usuário recém-cadastrado
      if params.has_key?(:invitation_token) &&
        invite = UserCourseInvitation.find_by_token(params[:invitation_token])

        invite.user = @user
        invite.accept!
      end

      # Invitation Token
      if params.has_key?(:friendship_invitation_token) &&
        invite = Invitation.find_by_token(params[:friendship_invitation_token])

        invite.accept!(@user)
      end

      flash[:notice] = t(:email_signup_thanks, :email => @user.email)
      respond_with(@user)
    else
      # Se tem um token de convite para o curso, atribui as variáveis
      # necessárias para mostrar o convite em Users#new
      if params.has_key?(:invitation_token) &&
        @user_course_invitation = UserCourseInvitation.find_by_token(
          params[:invitation_token])

        @course = @user_course_invitation.course
        @environment = @course.environment
      elsif params.has_key?(:friendship_invitation_token) &&
        invitation = Invitation.find_by_token(
          params[:friendship_invitation_token])

        @invitation_user = invitation.user
        uca = UserCourseAssociation.where(:user_id => @invitation_user).approved
        @contacts = {:total => @invitation_user.friends.count}
        @courses = { :total => @invitation_user.courses.count,
                     :environment_admin => uca.with_roles([:environment_admin]).count,
                     :tutor => uca.with_roles([:tutor]).count,
                     :teacher => uca.with_roles([:teacher]).count }
      end

      unless @user.oauth_token.nil?
        @user = User.find_by_oauth_token(@user.oauth_token)
        unless @user.nil?
          @user_session = UserSession.create(@user)
          current_user = @user_session.record
          flash[:notice] = t :thanks_youre_now_logged_in
          redirect_back_or_default user_path(current_user)
        else
          flash[:error] = t :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again
          respond_with(@user)
        end
      else
        respond_with(@user)
      end
    end
  end

  def edit
    @user.social_networks.build
    respond_to do |format|
      format.html { render :layout => 'new_application' }
    end
  end

  def curriculum
    # Usuário incluído para evitar diversas consultas; não foi passado o
    # @user para não perder legibilidade
    @experiences = @user.experiences.includes(:user)
    @educations = @user.educations.includes(:educationable, :user)

    @experience = Experience.new
    @high_school = HighSchool.new
    @higher_education = HigherEducation.new
    @complementary_course = ComplementaryCourse.new
    @event_education = EventEducation.new
    respond_to do |format|
      format.html { render :layout => 'new_application' }
    end
  end

  def update
    @user.attributes = params[:user]

    @user.tag_list = params[:tag_list] || ''

    if @user.errors.empty? && @user.save
      respond_to do |format|
        format.html do
          flash[:notice] = t :your_changes_were_saved
          unless params[:welcome]
            redirect_to(edit_user_path(@user))
          else
            redirect_to(:action => "welcome_#{params[:welcome]}", :id => @user)
          end
        end
      end
    else
      @experience = Experience.new
      @high_school = HighSchool.new
      @higher_education = HigherEducation.new
      @complementary_course = ComplementaryCourse.new
      @event_education = EventEducation.new
      @user.social_networks.build
      render 'users/edit', :layout => 'new_application'
    end

  rescue ActiveRecord::RecordInvalid
      render 'users/edit', :layout => 'new_application'
  end

  def update_account
    # Password atual não pode ficar em branco
    if params[:current_password].blank?
      # Só adiciona este erro se o usuário estiver tentando alterar sua senha
      if (!params[:user][:password].blank? ||
          !params[:user][:password_confirmation].blank?)
        @user.errors.add(:current_password, "A senha atual não pode ser deixada em branco.")
        params[:user][:password] = ""
        params[:user][:password_confirmation] = ""
      end
    else
      # Só altera a senha se o password atual estiver certo
      unless @user.valid_password? params[:current_password]
        @user.errors.add(:current_password, "A senha atual está errada.")
        params[:user][:password] = ""
        params[:user][:password_confirmation] = ""
      end
    end

    @user.attributes = params[:user]
    if @user.errors.empty? && @user.save
      flash[:notice] = t :your_changes_were_saved
      redirect_to(account_user_path(@user))
    else
      render 'users/account', :layout => 'new_application'
    end
  end

  def destroy
    @user.async_destroy
    flash[:notice] = t :the_user_was_deleted
    redirect_to home_path and return
  end

  def edit_account
    @user             = current_user
    @is_current_user  = true
  end

  def signup_completed
    redirect_to home_path and return unless @user
    render :template => "users/signup_completed", :layout => "cold"
  end

  def welcome_complete
    flash[:notice] = t(:walkthrough_complete, :site => Redu::Application.config.name)
    redirect_to user_path
  end

  def recover_username_password
    @recover_password = RecoveryEmail.new

    render :layout => 'cold'
  end

  def recover_password
    @recover_password = RecoveryEmail.new(params[:recovery_email])

    if @recover_password.valid?
      @user = User.find_by_email(@recover_password.email)

      if @user.nil?
        @recover_password.mark_email_as_invalid!
      else
        @user.generate_recovery_token
        #O usuario estava ficando logado, apos o comando @user.save.
        # Destruindo sessao caso ela exista.
        if UserSession.find
          UserSession.find.destroy
        end
      end
    end
  end

  def confirm_recover_password
    token = params[:token]
    @user = User.find_by_recovery_token(token)
    if @user.nil?
      redirect_to home_path
    else
      @user.reset_password

      UserNotifier.delay(:queue => 'email', :priority => 1).
          confirm_user_reseted_password(@user, @user.password)

      @user.recovery_token = nil
      @user.save

      if UserSession.find
        UserSession.find.destroy
      end

      render layout: 'cold'
    end
  end

  def resend_activation
    if params[:email]
      @user = User.find_by_email(params[:email])
    else
      @user = User.find(params[:id])
    end
    if @user
      flash[:notice] = t :activation_email_resent_message
      UserNotifier.delay(:queue => 'email').user_signedup(@user.id)

      if current_user_agent.mobile?
        redirect_to login_path and return
      else
        redirect_to application_path and return
      end
    else
      flash[:error] = t :activation_email_not_sent_message
    end
  end

  def home
    @friends_requisitions = @user.friendships.includes(:friend).pending
    @course_invitations = @user.course_invitations.
      includes(:course =>[:environment])
    @statuses = @user.home_activity(params[:page])
    @status = Status.new

    respond_to do |format|
      format.html { render layout: 'new_application' }
      format.js do
        render_endless 'statuses/item', @statuses, '#statuses',
          template: 'shared/new_endless_kaminari'
      end
    end
  end

  def my_wall
    @statuses = @user.statuses.visible.page(params[:page]).per(10)
    @status = Status.new

    respond_to do |format|
      format.html { render layout: 'new_application' }
      format.js do
        render_endless 'statuses/item', @statuses, '#statuses',
          template: 'shared/new_endless_kaminari'
      end
    end
  end

  def account
    respond_to do |format|
      format.html { render :layout => 'new_application' }
    end

  end

  # Dada uma palavra-chave retorna json com usuários que possuem aquela palavra.
  def auto_complete
    if params[:q] # Usado em invitations: todos os users
      @users = User.with_keyword(params[:q])
      @users = @users.map do |u|
        { :id => u.id, :name => u.display_name, :avatar_32 => u.avatar.url(:thumb_32),
          :mail => u.email, :profile_link => user_path(u) }
      end
    elsif params[:tag] # Usado em messages: somente amigos
      @users = current_user.friends.with_keyword(params[:tag])
      @users = @users.map do |u|
        {:key => "<img src=\"#{ u.avatar(:thumb_32) }\"/> #{ u.display_name }", :value => u.id}
      end
    end

    respond_to do |format|
      format.js do
        render :json => @users
      end
    end
  end

  def show_mural
    if @user.removed
      redirect_to removed_page_path and return
    end

    @statuses = @user.statuses.where(:compound => false).page(params[:page]).
      per(Redu::Application.config.items_per_page)
    @statusable = @user
    @status = Status.new

    @subscribed_courses_count = @user.user_course_associations.approved.count

    respond_to do |format|
      format.html { render layout: 'new_application' }
      format.js do
        render_endless 'statuses/item', @statuses, '#statuses',
          :template => 'shared/new_endless_kaminari'
      end
    end
  end

  def index
    load_hierarchy
    entity = @space || @course || @environment
    authorize! :preview, entity

    if @course
     @responsibles_associations = @course.user_course_associations.
      with_roles([Role[:teacher], Role[:environment_admin]]).includes(:user)
    end

    @users = if params[:role].eql? "teachers"
      entity.teachers
    elsif params[:role].eql? "tutors"
      entity.tutors
    elsif params[:role].eql? "students"
      entity.students
    else
      if @course
        entity.approved_users
      else
        entity.users
      end
    end

    @users = @users.order('first_name ASC').page(params[:page]).per(18)

    respond_to do |format|
      format.html do
        render "#{entity.class.to_s.downcase.pluralize}/users/index"
      end
      format.js do
          render_endless 'users/item', @users, '#users-list',
            :partial_locals => { :entity => entity }
      end
    end
  end

  def new
    redirect_to application_path(:anchor => "modal-sign-up")
  end

  protected

  def deny_access(exception)
    session[:return_to] = request.fullpath
    if exception.action == :preview && exception.subject.class == Space
      if current_user.nil?
        flash[:info] = "Essa área só pode ser vista após você acessar o #{Redu::Application.config.name} com seu nome e senha."
      else
        flash[:info] = "Você não tem acesso a essa página"
      end

      redirect_to preview_environment_course_path(@space.course.environment,
                                                  @space.course)
    else
      super
    end
  end


  def load_hierarchy
    if environment_id = params[:environment_id]
      @environment = Environment.find_by_path(environment_id)

      if course_id = params[:course_id]
        @course = @environment.courses.find_by_path(course_id)
      end
    end

    if space_id = params[:space_id]
      @space = Space.find(space_id)
    end
  end

  def remove_errors_field
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag
    end
  end
end
