# -*- encoding : utf-8 -*-
module Api
  class UsersController < ApiController
    #skip_authorization_check :only => :create
    def show
      @user = if params[:id]
        User.find(params[:id])
      else
        current_user
      end

      authorize! :read, @user
      respond_with @user
    end

    # /api/spaces/:space_id/users
    # /api/courses/:course_id/users
    # /api/environments/:environment_id/users
    def index
      context = context(params)
      authorize! :read, context

      users = users_with_indiferent_access(context)
      users = filter_by_role(context, users, params[:role]) if params[:role]

      if params[:partial]
        respond_with(users) do |format|
          format.json { render json: users.to_json(only: [:id, :first_name, :last_name]) }
        end
      else
        users = users.includes(:social_networks, :tags)
        respond_with(:api, context, users)
      end
    end

    #first_name, last_name, password, login, email
    def create
      authorize! :create_via_api, @user
      user = User.new(params[:user])

      if user.save
        user.activate
        user.create_settings!
        userPass = params[:user][:password]
        UserNotifier.delay(queue: 'email', priority: 1).user_added_to_application(user.id, userPass)
      end

      respond_with user
    end


    protected

    def context(params)
      if params.has_key?(:course_id)
        Course.find(params[:course_id])
      elsif params.has_key?(:environment_id)
        Environment.find(params[:environment_id])
      elsif params.has_key?(:user_id)
        User.find(params[:user_id])
      else
        Space.find(params[:space_id])
      end
    end

    def filter_by_role(context, users, role)
      case context
      when Space
        users.where(user_space_associations: { role: Role[role.to_sym] })
      when Environment
        users.where(user_environment_associations: { role: Role[role.to_sym] })
      when Course
        users.where(course_enrollments: { role: Role[role.to_sym] })
      else
        users
      end
    end

    def users_with_indiferent_access(context)
      # please Anything#users by convetion.
      context.respond_to?(:users) ? context.users : context.friends
    end
  end
end
