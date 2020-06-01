# -*- encoding : utf-8 -*-
class CoursesController < BaseController
  respond_to :html, :js

  before_filter Proc.new {
    @environment = Environment.find_by_path(params[:environment_id])
    @course = @environment.courses.find(:first,
                                        conditions: { path: params[:id] },
                                        include: [:audiences])
  }, only: :edit

  after_filter :update_last_access, only: [:show]

  load_resource :environment, find_by: :path
  load_and_authorize_resource :course, through: :environment,
    except: [:index], find_by: :path

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.fullpath

    if @course.blocked?
      flash[:info] = "Entre em contato com o administrador deste curso."
    elsif current_user.nil?
      flash[:info] = "Essa área só pode ser vista após você acessar o #{Redu::Application.config.name} com seu nome e senha."
    else
      flash[:info] = "Você não tem acesso a essa página"
    end

    if current_user
      redirect_to preview_environment_course_path(@environment, @course)
    else
      redirect_to home_path
    end
  end

  def show
    @responsibles_associations = responsibles_associations_of(@course)
    @spaces = @course.spaces.published.order('created_at ASC').
      page(params[:page]).per(Redu::Application.config.items_per_page)

    respond_with(@environment, @course) do |format|
      format.js { render_endless 'spaces/item', @spaces, '#spaces_list' }
    end
  end

  def edit
    respond_to do |format|
      format.html { render 'courses/admin/edit' }
    end
  end

  def destroy
    @course.async_destroy

    respond_to do |format|
      flash[:notice] = "Curso removido."
      format.html { redirect_to(environment_path(@environment)) }
      format.xml  { head :ok }
    end
  end

  def update
    @header_course = @course.clone

    respond_to do |format|
      if @course.update_attributes(params[:course])
        if params[:course][:subscription_type].eql? "1"
          #FIXME delay
          @course.user_course_associations.waiting.each do |ass|
            ass.approve!
          end
        end

        flash[:notice] = 'O curso foi editado.'
        format.html { redirect_to(environment_course_path(@environment, @course)) }
        format.xml { head :ok }
      else
        format.html { render 'courses/admin/edit' }
        format.xml  { render xml: @course.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  def new
    respond_to do |format|
      format.html { render 'courses/admin/new' }
    end
  end

  def create
    authorize! :manage, @environment #Talvez seja necessario pois o @environment não está sendo autorizado.

    @course.owner = current_user
    respond_to do |format|
      if @course.save
        if @environment.plan.nil?
          @plan = Plan.from_preset(:professor_plus)
          @plan.user = current_user
          @course.create_quota
          @course.plan = @plan
        end
        @environment.courses << @course
        format.html { redirect_to environment_course_path(@environment, @course) }
      else
        format.html { render 'courses/admin/new' }
      end
    end

  end

  # Visão do Course para usuários não-membros.
  def preview
    #FIXME please. Used for redirect to a valid url
    if params[:id] == 'Primeiro Ano do Ensino Médio 2011'
      redirect_to preview_environment_course_path(@environment, Course.find(88)) and return
    end

    if can? :read, @course
      redirect_to environment_course_path(@environment, @course) and return
    end

    # Ao retornar, usário é direcionado a página de preview, pois se voltar
    # para o show poderá receber mensagens de acesso negado que irão
    # confundí-lo
    session[:return_to] = request.fullpath

    @responsibles_associations = responsibles_associations_of(@course)
    @spaces = @course.spaces.order('name ASC').page(params[:page]).
      per(Redu::Application.config.items_per_page)
    respond_to do |format|
      format.html { render layout: 'new_application' }
      format.js do
        render_endless 'spaces/item_short', @spaces, '#course-preview > ul'
      end
    end
  end

  # Aba Disciplinas.
  def admin_spaces
    @spaces = @course.spaces.includes(:subjects).order('updated_at DESC').
      page(params[:page]).per(Redu::Application.config.items_per_page)

    # Para evitar diversas consultas, a contagem de membros é feita apenas uma vez
    unless @spaces.empty?
      users_count = @spaces.first.users.count
      @spaces.map { |s| s.member_count = users_count }
    end

    respond_to do |format|
      format.html { render "courses/admin/admin_spaces" }
      format.js do
        render_endless 'spaces/admin/item_admin', @spaces, '#spaces_list'
      end
    end
  end

  # Aba Moderação de Membros.
  def admin_members_requests
    # FIXME Refatorar para o modelo (conditions)
    @pending_members = @course.user_course_associations.waiting.
      order('updated_at DESC').page(params[:page]).
      per(Redu::Application.config.items_per_page)
    respond_to do |format|
      format.html { render "courses/admin/admin_members_requests" }
      format.js do
        render_endless 'courses/admin/pending_member_item_admin', @pending_members,
          '#pending_member_list'
      end
    end
  end

  # Modera os usuários.
  def moderate_members_requests
    if params[:member].nil?
      flash[:error] = "Escolha, pelo menos, algum usuário."
    else
      approved = params[:member].reject{|k,v| v == 'reject'}
      rejected = params[:member].reject{|k,v| v == 'approve'}

      # Rejeitando
      rejected_ucas = @course.user_course_associations.waiting.
        where(user_id: rejected.keys)
      rejected_ucas.each do |uca|
        UserNotifier.delay(queue: 'email').reject_membership(uca.user, @course)
        uca.destroy
      end

      # verifica se o limite de usuário foi atingido
      if can?(:add_entry?, @course) and !approved.to_hash.empty?
        # calcula o total de usuarios que estão para ser aprovados
        # e só aprova aqueles que estiverem dentro do limite
        total_members = @course.approved_users.count + approved.count
        members_limit = @course.plan.try(:members_limit) ||
          @course.environment.plan.try(:members_limit)
        if total_members > members_limit
          # remove o usuários que passaram do limite
          (total_members - members_limit).times do
            approved.shift
          end
          flash[:error] = "O limite máximo de usuários foi atigindo, apenas alguns membros foram moderados."
        else
          flash[:notice] = 'Membros moderados!'
        end

        # Aprovando
        approved_ucas = @course.user_course_associations.waiting.
          where(user_id: approved.keys)
        approved_ucas.each do |uca|
          uca.approve!
          UserNotifier.delay(queue: 'email').approve_membership(uca.user, @course)
        end
      elsif can?(:add_entry?, @course) and !rejected.to_hash.empty?
        # Avisa que os membros rejeitados foram moderados mesmo se não houver membros para serem aprovados
        flash[:notice] = 'Membros moderados!'
      else
        if rejected.to_hash.empty?
          flash[:error] = "O limite máximo de usuários foi atingido. Não é possível adicionar mais usuários."
        else
          flash[:error] = "O limite máximo de usuários foi atingido. Só os usuários rejeitados foram moderados."
        end
      end
    end

    redirect_to admin_members_requests_environment_course_path(@environment, @course)
  end

  # Associa um usuário a um Course (Ação de participar).
  def join
    authorize! :add_entry, @course

    @course.join(current_user)

    if @course.subscription_type.eql? 1 # Todos podem participar, sem moderação
      flash[:notice] = "Você agora faz parte do curso #{@course.name}"
      redirect_to environment_course_path(@course.environment, @course)
    else
      flash[:notice] = "Seu pedido de participação foi feito. Aguarde a moderação."
      redirect_to preview_environment_course_path(@course.environment, @course)
    end
  end


  # Desassocia um usuário de um Course (Ação de sair do Course).
  def unjoin
    @course.unjoin current_user

    flash[:notice] = "Você não participa mais do curso #{@course.name}"
    redirect_to environment_course_path(@course.environment, @course)
  end

  def publish
    @course.published = 1
    @course.save
    flash[:notice] = "O curso #{@course.name} foi publicado."

    redirect_to environment_course_path(@environment, @course)
  end

  def unpublish
    @course.published = 0
    @course.save

    flash[:notice] = "O curso #{@course.name} foi despublicado."
    redirect_to environment_course_path(@environment, @course)
  end

  # Aba Membros.
  def admin_members
    @memberships = @course.user_course_associations.approved.
                     includes(:user).order('updated_at DESC').
                     page(params[:page]).
                     per(Redu::Application.config.items_per_page)
    @spaces_count = @course.spaces.count

      respond_to do |format|
        format.html { render "courses/admin/admin_members" }
        format.js do
          render_endless 'courses/admin/user_item_admin', @memberships,
            '#user_list_table', partial_locals: { spaces_count:
                                                     @spaces_count }
        end
      end
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    # Course.id do environment
    spaces = @course.spaces
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      User.select(:id).where(id: users_ids).
        find_in_batches(batch_size: 100) do |users|

        users.each do |u|
          job = UnjoinUserJob.new(user: u, course: @course)
          Delayed::Job.enqueue(job, queue: 'general')
        end
      end

      flash[:notice] = "Os usuários estão sendo removidos do curso. Esta operação poderá levar alguns minutos."
    end

    respond_to do |format|
      format.html { redirect_to action: :admin_members }
    end
  end

  def search_users_admin
    roles = []
    roles = params[:role_filter].collect {|r| r.to_s} if params[:role_filter]
    keyword = params[:search_user] || []

    @memberships = @course.user_course_associations.approved.with_roles(roles)
    @memberships = @memberships.with_keyword(keyword).
      includes(user: {user_space_associations: :space}).
      order('course_enrollments.updated_at DESC').page(params[:page]).
      per(Redu::Application.config.items_per_page)
    @spaces_count = @course.spaces.count

      respond_to do |format|
        format.js { render "courses/admin/search_users_admin" }
      end
  end

  # Aceitar convite para o Course
  def accept
    authorize! :add_entry, @course

    assoc = current_user.get_association_with @course
    assoc.accept!

    respond_to do |format|
      format.html do
        redirect_to home_user_path(current_user)
      end
      format.js do
        @item_invitation = assoc
      end
    end
  end

  # Negar convite para o Course
  def deny
    assoc = current_user.get_association_with @course
    assoc.deny!
    assoc.destroy

    respond_to do |format|
      format.html do
        redirect_to home_user_path(current_user)
      end
      format.js do
        @item_invitation = assoc
      end
    end
  end

  def invite_members
    @users = params[:users] || ""
    @users = @users.split(",").uniq.compact
    @users = User.find(@users)

    @users.each do |user|
      @course.invite(user)
    end

    @emails = params[:emails] || ""
    @emails = @emails.split(",").uniq.compact
    @emails.delete("")
    @emails.each do |e|
      @course.invite_by_email(e)
    end


    respond_to do |format|
      format.html do
        if @users.empty? && @emails.empty?
          flash[:error] = "Nenhum usuário foi informado."
        else
          flash[:notice] = "Os usuários foram convidados via e-mail."
        end

        redirect_to admin_invitations_environment_course_path(@environment, @course)
      end

      format.js do
        @invitation_id = params[:invitation_id]
      end
    end
  end

  # Página para convidar usuários para o curso
  def admin_invitations
    @responsibles_associations = responsibles_associations_of(@course)

    respond_to do |format|
      format.html
    end
  end

  # Página para administrar convites já enviados
  def admin_manage_invitations
    @email_invitations = @course.user_course_invitations.invited
    @user_invitations = @course.user_course_associations.invited

    respond_to do |format|
      format.html { render "courses/admin/admin_manage_invitations" }
    end
  end

  def destroy_invitations
    email_invitations = to_array(params[:email_invitations])
    user_invitations = to_array(params[:user_invitations])

    email_invitations = email_invitations.map(&:to_i)
    user_invitations = user_invitations.map(&:to_i)

    email_invitations.each do |i|
      invitation = UserCourseInvitation.find(i)
      invitation.destroy
    end

    user_invitations.each do |i|
      assoc = UserCourseAssociation.find(i)
      assoc.destroy
    end

    if email_invitations.empty? && user_invitations.empty?
      flash[:error] = "Nenhum convite foi marcado para ser removido."
    else
      flash[:notice] = "Os convites foram removidos do curso #{@course.name}."
    end

    respond_to do |format|
      format.html { redirect_to action: :admin_manage_invitations }
    end
  end

  def teacher_participation_report
    respond_to do |format|
      format.html { render 'courses/admin/teacher_participation_report'}
    end
  end

  protected

  def update_last_access
    uca = current_user.get_association_with(@course)
    uca.touch(:last_accessed_at) if uca
  end

  def to_array(parameter)
    parameter.blank? ? [] : parameter
  end

  def responsibles_associations_of(course)
    course.user_course_associations.
      with_roles([Role[:teacher], Role[:environment_admin]]).includes(:user)
  end
end
