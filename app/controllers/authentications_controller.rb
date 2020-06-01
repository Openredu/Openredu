# -*- encoding : utf-8 -*-
class AuthenticationsController < BaseController

  def create
    auth = request.env['omniauth.auth']
    auth_service = AuthenticationService.new(:omniauth => auth)

    current_user = nil

    if auth_service.authenticate?
      if auth_service.connected_accounts?
        flash[:notice] = t :facebook_connect_account_association
      else
        flash[:notice] = t :thanks_youre_now_logged_in
      end

      # Usuário criado / atualizado com sucesso
      @user_session = UserSession.new(auth_service.authenticated_user)
      current_user = @user_session.record if @user_session.save

      # Lida com tokens de convites
      if params[:state]
        Authentication.handle_invitation_token(params[:state], current_user)
      end

      if valid_url?(params[:state])
        redirect_to params[:state]
      else
        redirect_to session[:return_to] || home_user_path(current_user)
        session[:return_to] = nil
      end
    else
      flash[:error] = t :facebook_connect_error

      @user = auth_service.authenticated_user
      @user_session = UserSession.new
      params[:opened_signup_modal] = "open-me"
      render 'base/site_index', :layout => 'basic'
    end
  end

  def fallback
    flash[:error] = t :you_need_give_us_access_to_your_facebook_data
    redirect_to application_path
  end

  private

  # Verifica se a url pertence ao domínio de algum serviço do Redu
  #
  # valid_url?("http://aplicativos.redu.com.br/apps/86")
  # => true
  #
  # valid_url?("http://hack.com")
  # => false
  def valid_url?(url)
    Redu::Application.config.redu_services.values.collect do |service|
      url.try(:include?, service[:url])
    end.inject(:^)
  end
end
