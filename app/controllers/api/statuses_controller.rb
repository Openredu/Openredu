# -*- encoding : utf-8 -*-
module Api
  class StatusesController < Api::ApiController
    ALLOWED_LOGEABLE_TYPE = %w(Course Subject Lecture Space User CourseEnrollment)
    ALLOWED_STATUS_TYPE = %w(Log Help Activity)

    def show
      status = Status.includes(user: :social_networks).find(params[:id])
      authorize! :read, status

      respond_with(:api, status)
    end

    def create
      status = Status.new(params[:status]) do |s|
        s.statusable = context(params)
        s.user = current_user
        s.type = params[:status].fetch(:type, 'Activity').camelize
      end

      authorize! :read, status.statusable

      # Transformando numa instancia do filho do sti
      status = status.becomes(status.type.constantize)
      if status.save
        respond_with(:api, status, location: api_status_url(status))
      else
        respond_with(:api, status)
      end
    end

    def index
      context = context(params)
      authorize! :read, context
      statuses = statuses(context)

      statuses = filter_by_type(statuses, params)

      statuses = statuses.page(params[:page])

      respond_with_statuses(statuses)
    end

    def destroy
      status = Status.find(params[:id])
      authorize! :manage, status

      status.destroy

      respond_with(:api, status)
    end

    def timeline
      statusable = context(params)
      authorize! :read, statusable

      statuses = if statusable.is_a?(Space)
        statusable.activities
      else
        statusable.overview
      end

      statuses = filter_and_includes(statuses)
      statuses = filter_by_type(statuses, params)
      statuses = statuses.page(params[:page])

      respond_with_statuses(statuses)
    end

    protected

    def respond_with_statuses(statuses)
      respond_with(:api, statuses) do |format|
        format.json { render json: statuses.extend(StatusesRepresenter) }
      end
    end

    def context(params)
      if params[:space_id]
        Space.find(params[:space_id])
      elsif params[:lecture_id]
        Lecture.find(params[:lecture_id])
      else
        User.find(params[:user_id])
      end
    end

    def statuses(context)
      statuses = if context.is_a? User
        Status.where(user_id: context)
      else
        Status.where(statusable_id: context,
                     statusable_type: context.class.to_s)
      end
      filter_and_includes(statuses).order('created_at DESC')
    end

    def filter_and_includes(statuses)
      statuses = statuses.not_compound_log

      log_filter = if params.has_key?(:logeable_type)
                     ALLOWED_LOGEABLE_TYPE & [params[:logeable_type]].flatten
                   else
                     ALLOWED_LOGEABLE_TYPE
                   end
      statuses = statuses.
        where("statuses.logeable_type IN (?) OR statuses.logeable_type IS NULL", log_filter)
      statuses = statuses.includes(user: :social_networks)
    end

    def filter_by_type(statuses, params)
      types = params[:type] || params[:types] || []
      types = types.respond_to?(:map) ? types : [types]
      types = types.map(&:classify) & ALLOWED_STATUS_TYPE

      return statuses if types.empty?
      statuses.where(type: types)
    end
  end
end
