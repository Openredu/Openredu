# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user

  before_filter :detect_mobile
  after_filter :check_tour_exploration

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  rescue_from CanCan::AccessDenied, :with => :deny_access

  def routing_error
    respond_to do |format|
      format.html {
        render :template => 'errors/404', :layout => 'cold', :status => '404'
      }
    end
  end

  def redirect_to(options = {}, response_status = {})
    ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
    super(options, response_status)
  end

  private

  def single_access_allowed?
    controller_path.split("/").first == 'api'
  end

  # Handlers para exceções (paginas de error customizadas)
  def render_not_found(exception)
    logger.error exception
    respond_to do |format|
      format.html {
        render :template => 'errors/404', :layout => 'cold', :status => '404'
      }
    end
  end

  def render_error(exception)
    @contact = Contact.new
    logger.error exception
    respond_to do |format|
      format.html {
        render :template => 'errors/500', :layout => 'cold', :status => '500'
      }
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def last_request_update_allowed?
    false
  end

  def check_tour_exploration
    return if current_user.nil? || !params.has_key?(:exploring_tour)
    current_user.settings.visit!(request.path)
  end

  def detect_mobile
    if current_user_agent.mobile?
      prepend_view_path "app/views/mobile"
    end
  end

  def deny_access(exception, &block)
    session[:return_to] ||= request.fullpath

    flash[:error] = "Essa área só pode ser vista após você acessar o #{Redu::Application.config.name} com seu nome e senha."

    puts exception.action
    puts exception.subject

    yield if block_given?

    if current_user_agent.mobile?
      redirect_to login_path
    else
      redirect_to home_path
    end
  end

  def current_user_agent
    @current_user_agent ||= UserAgent.parse(request.user_agent)
  end
end
