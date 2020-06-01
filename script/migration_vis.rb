# -*- encoding : utf-8 -*-
#!/usr/bin/env ruby
# Script para alimentação do banco da aplicação de vis do Redu

require 'logger'

class Conflict < StandardError
end
class BadRequest < StandardError
end
class ConnectionError < StandardError
end

def insert_enrollments(date)
  Enrollment.where("created_at >= '#{date}'").find_each do |enrollment|
    unless enrollment.subject.nil?
      unless enrollment.subject.space.nil?
        unless enrollment.subject.space.course.nil?
          params_enroll = fill_enroll(enrollment, "enrollment")
          send_async_info(params_enroll,
                          Redu::Application.config.vis_client[:url])
        end
      end
    end
  end
end

def insert_subject_finalized(date)
  Enrollment.where("grade = 100 AND graduated = true AND created_at >= '#{date}'").find_each do |profile|
    params_finalized = fill_enroll(profile, "subject_finalized")
    send_async_info(params_finalized,
                    Redu::Application.config.vis_client[:url])
  end
end

def insert_exercise_finalized(date)
  Exercise.where("created_at > '#{date}'").find_each do |exercise|
    exercise.results.finalized.each do |finalized|
      params = fill_exercise(finalized)
      send_async_info(params,
                      Redu::Application.config.vis_client[:url])
    end
  end
end

def insert_statuses(date)
  Status.where("type IN ('Activity', 'Help', 'Answer') AND created_at >= '#{date}'").find_each do |status|

    # Filling params according type of the Status
    case status.statusable.class.to_s
    when "Lecture"
      @lecture_id = status.statusable_id
      @subject_id = status.statusable.subject.id
      @space_id = status.statusable.subject.space.id
      @course_id = status.statusable.subject.space.course.id

      send_statuses(status)
    when "Space"
      @lecture_id = nil
      @subject_id = nil
      @space_id = status.statusable.id
      @course_id = status.statusable.course.id

      send_statuses(status)
    when "Activity", "Help"
      statusable = status.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        @lecture_id = statusable.statusable_id
        @subject_id = statusable.statusable.subject.id
        @space_id = statusable.statusable.subject.space.id
        @course_id = statusable.statusable.subject.space.course.id

        send_statuses(status)
      when "Space"
        @lecture_id = nil
        @subject_id = nil
        @space_id = statusable.statusable.id
        @course_id = statusable.statusable.course.id

        send_statuses(status)
      end
    end
  end
end

def remove_enrollments(date)
  Enrollment.where("created_at >= '#{date}'").find_each do |enrollment|
    if !enrollment.nil? && !enrollment.user.nil?
      if (enrollment.user.get_association_with enrollment.subject.space).nil?
        params_remove_enrollment = fill_enroll(enrollment, "remove_enrollment")

        send_async_info(params_remove_enrollment,
                        Redu::Application.config.vis_client[:url])

        if enrollment.grade == 100 and enrollment.graduated
          params_finalized = fill_enroll(enrollment, "remove_subject_finalized")
          send_async_info(params_finalized,
                          Redu::Application.config.vis_client[:url])
        end

        enrollment.try(:destroy)
      end
    end
  end
end

def send_statuses(status)
  params_status = {
    :user_id => status.user_id,
    :type => get_type(status),
    :lecture_id => @lecture_id,
    :subject_id => @subject_id,
    :space_id => @space_id,
    :course_id => @course_id,
    :status_id => status.id,
    :statusable_id => status.statusable_id,
    :statusable_type => status.statusable_type,
    :in_response_to_id => status.in_response_to_id,
    :in_response_to_type => status.in_response_to_type,
    :created_at => status.created_at,
    :updated_at => status.updated_at
  }

  send_async_info(params_status,
                       Redu::Application.config.vis_client[:url])
end

def get_type(status)
  if status.type == "Help" or status.type == "Activity"
    status.type.downcase
  elsif status.type == "Answer"
    if status.statusable.type == "Help"
      "answered_help"
    else
      "answered_activity"
    end
  else
    nil
  end
end

def fill_enroll(enrollment, type)
  params_enrol = {
    :user_id => enrollment.user_id,
    :type => type,
    :lecture_id => nil,
    :subject_id => enrollment.subject_id,
    :space_id => enrollment.subject.space.id,
    :course_id => enrollment.subject.space.course.id,
    :status_id => nil,
    :statusable_id => nil,
    :statusable_type => nil,
    :in_response_to_id => nil,
    :in_response_to_type => nil,
    :created_at => enrollment.created_at,
    :updated_at => enrollment.updated_at
  }
end

def fill_exercise(result)
  exercise = result.exercise
  space = exercise.lecture.subject.space
  params = {
    :lecture_id => exercise.lecture.id,
    :subject_id => exercise.lecture.subject.id,
    :space_id => space.id,
    :course_id => space.course.id,
    :user_id => result.user_id,
    :type => "exercise_finalized",
    :grade => result.grade,
    :status_id => nil,
    :statusable_id => nil,
    :statusable_type => nil,
    :in_response_to_id => nil,
    :in_response_to_type => nil,
    :created_at => result.created_at,
    :updated_at => result.updated_at
  }
end

def send_async_info(params, url)
  EM.run {
    http = EM::HttpRequest.new(url).post({
      :body => params.to_json,
      :head => {'Authorization' => ["core-team", "JOjLeRjcK"],
                'Content-Type' => 'application/json' }
    })

    http.callback {
      begin
        handle_response(http.response_header.status)
      rescue
        log = Logger.new("log/script_error.log")
        log.error "Callback, error with code: #{http.response_header.status}, with params: #{params.inspect}"
        log.close
      end
    EM.stop
    }

    http.errback {
      begin
        handle_response(http.response_header.status)
      rescue
        log = Logger.new("log/error.log")
        log.error "Errback: Bad DNS or Timeout, code:#{http.response_header.status}"
        log.close
      end
    EM.stop
    }
  }
end

def handle_response(status_code)
  case status_code
  when 200
    return true
  when 201
    return true
  when 202
    return true
  when 400
    raise BadRequest, "Bad request"
  when 409
    raise Conflict, "Conflict"
  else
    raise ConnectionError, "Unknown error (status code #{status_code}): #{body}"
  end
end
