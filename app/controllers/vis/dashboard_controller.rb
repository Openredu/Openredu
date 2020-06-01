# -*- encoding : utf-8 -*-
module Vis
  class DashboardController < VisualizationsController

    # Interação do usuário
    def teacher_participation_interaction
      data_year_start = params[:date_start_fake]['(1i)']
      data_month_start = params[:date_start_fake]['(2i)']
      data_day_start = params[:date_start_fake]['(3i)']
      data_year_end = params[:date_end_fake]['(1i)']
      data_month_end = params[:date_end_fake]['(2i)']
      data_day_end = params[:date_end_fake]['(3i)']

      d_s = DateTime.new(
        data_year_start.to_i,
        data_month_start.to_i,
        data_day_start.to_i
      )

      d_e = DateTime.new(
        data_year_end.to_i,
        data_month_end.to_i,
        data_day_end.to_i
      )


      if params[:teacher_id].nil?
        self.generate_erro("Não existem professores neste curso")
      elsif params[:spaces].nil?
        self.generate_erro("Não existem disciplinas no curso")
      elsif d_s > d_e
        self.generate_erro("Intervalo de tempo inválido")
      else
        # params [:course_id]
        @course = Course.find(params[:course_id])
        authorize! :teacher_participation_interaction, @course

        # params [:teacher_id]
        @teacher = @course.teachers.find(params[:teacher_id])
        @uca = @teacher.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)

        # params [:date_start, :date_end] => time (format): "year-month-day"
        @participation.start = d_s
        @participation.end = d_e

        # params [:spaces[id.to_s]]
        @spaces = params[:spaces].join(',').split(',')
        @participation.spaces = @uca.course.spaces.find(@spaces)

        self.generate_json
      end
    end

    protected

    def generate_erro(msg)
      @error = Error.new(msg)
      respond_to do |format|
        format.json { render :json => @error.extend(ErrorRepresenter)}
      end
    end

    def generate_json
      @participation.generate!
      @participation.extend(TeacherParticipationRepresenter)

      respond_to do |format|
        format.json { render :json => @participation,
                      :callback => params[:callback] }
      end
    end
  end
end
