# -*- encoding : utf-8 -*-
module Api
  class ApiController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    represents :json, collection: CollectionRepresenter
    before_filter :extract_single_access_token

    check_authorization

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveModel::MissingAttributeError, with: :bad_request
    rescue_from CanCan::AccessDenied, with: :not_authorized

    def routing_error; bad_request end

    private

    def self.responder
      Class.new(super).send :include, Api::Responder
    end

    def not_authorized
      authorize! :read, :error
      error = { message: 'not authorized', action: params[:action] }
      respond_to do |format|
        format.json { render json: error, status: :unauthorized }
      end
    end

    def not_found
      authorize! :read, :error

      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end

    def bad_request
      authorize! :read, :error
      respond_to do |format|
        format.json { render nothing: true, status: :bad_request }
      end
    end

    def current_ability
      @current_ability = Api::Ability.new(current_user)
    end

    protected

    def current_user
      current_access_token.try(:user) || User.where(:single_access_token => params[:user_credentials]).first
    end


    def current_access_token
      env["oauth.token"]
    end

    def extract_single_access_token
      if(request.headers['Authorization'].present? && request.headers['AppKey'].present?)
        params[:user_credentials] = appkey_is_valid? ? request.headers['Authorization'] : nil
      end
    end

    def appkey_is_valid?
      request.headers['AppKey'] == ENV['MOBILE_API_TOKEN']
    end
  end
end
