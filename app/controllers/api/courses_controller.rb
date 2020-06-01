# -*- encoding : utf-8 -*-
module Api
  class CoursesController < ApiController
    def index
      @environment = Environment.find(params[:environment_id])
      authorize! :read, @environment
      @courses = @environment.try(:courses) || []

      respond_with :api, @environment, @courses
    end

    def show
      @course = Course.find(params[:id])
      authorize! :read, @course

      respond_with :api, @course
    end

    def create
      authorize! :create, Environment
      @environment = Environment.find(params[:environment_id])
      @course = Course.new(params[:course]) do |c|
        c.environment = @environment
        c.owner = current_user
      end
      @course.save
      @plan = Plan.from_preset(params[:course][:plan].try(:to_sym))
      @plan.user = current_user
      @course.plan = @plan
      @plan.save
      @course.create_quota

      respond_with :api, @course
    end

    def update
      @course = Course.find(params[:id])
      authorize! :manage, @course
      @course.update_attributes(params[:course])

      respond_with @course
    end

    def destroy
      @course = Course.find(params[:id])
      authorize! :manage, @course
      @course.destroy

      respond_with :api, @course
    end
  end
end
