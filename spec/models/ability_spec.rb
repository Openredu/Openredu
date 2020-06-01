# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  context "on hierarchy" do
    before do
      @env_admin = FactoryGirl.create(:user)
      @member = FactoryGirl.create(:user)
      @teacher = FactoryGirl.create(:user)
      @tutor = FactoryGirl.create(:user)
      @redu_admin = FactoryGirl.create(:user, :role => :admin)
    end

    context "on environment -" do

      before do
        @environment = FactoryGirl.create(:environment, :owner => @env_admin)
      end

      context "member" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          @ability = Ability.new(@member)
        end
        it "creates a environment" do
          env = FactoryGirl.build(:environment, :owner => @member)
          @ability.should be_able_to(:create, env)
        end

        it "destroys his own environment" do
          @ability.should be_able_to(:destroy, FactoryGirl.create(:environment, :owner => @member))
        end
        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end

        it "cannot manage an environment" do
          @ability.should_not be_able_to(:manage, @environment)
        end
      end

      context "envinronment_admin" do
        before do
          @ability = Ability.new(@env_admin)
        end
        #FIXME aparentemente um usuário pode criar um ambiente em que o owner seja outro usuário
        it "creates a environment" do
          @ability.should be_able_to(:create, FactoryGirl.build(:environment,
                                                            :owner => @env_admin))
        end
        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, @environment)
        end

        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy,
                                         FactoryGirl.build(:environment,
                                                       :owner => @redu_admin))
        end

        it "can manage his own environment" do
          @ability.should be_able_to(:manage, @environment)
        end

        it "can preview a environment" do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          @ability.should be_able_to(:preview, @environment)
        end
      end

      context "teacher" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          @ability = Ability.new(@teacher)
        end

        it "creates a environment" do
          @ability.should be_able_to(:create,
                                     FactoryGirl.build(:environment,
                                                   :owner => @teacher))
        end
        it "destroy his own environment" do
          @ability.should be_able_to(:destroy,
                                     FactoryGirl.create(:environment,
                                             :owner => @teacher))
        end
        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end

        it "cannot manage a strange environment" do
          @ability.should_not be_able_to(:manage, @environment)
        end
      end

      context "tutor" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :teacher)
          @ability = Ability.new(@tutor)
        end
        it "creates a environment" do
          @ability.should be_able_to(:create, FactoryGirl.build(:environment,
                                                            :owner => @tutor))
        end

        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, FactoryGirl.create(:environment,
                                                       :owner => @tutor))
        end

        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end

        it "cannot manage a strange environment" do
          @ability.should_not be_able_to(:manage, @environment)
        end
      end

      context "redu admin" do
        before do
          @ability = Ability.new(@redu_admin)
        end
        it "creates a environment" do
          @ability.should be_able_to(:create,
                                     FactoryGirl.build(:environment,
                                                   :owner => @redu_admin))
        end

        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, FactoryGirl.create(:environment,
                                                       :owner => @redu_admin))
        end
        it "can destroy a strange environment" do
          @ability.should be_able_to(:destroy, @environment)
        end

        it "can manage a strange environment" do
          @ability.should be_able_to(:manage, @environment)
        end
       end

      context "strange" do
        before do
          @strange = FactoryGirl.create(:user)
          @ability = Ability.new(@strange)
        end

        it "can preview a environment" do
          @ability.should be_able_to(:preview, @environment)
        end

        it "cannot manage a environment" do
          @ability.should_not be_able_to(:manage, @environment)
        end
      end
    end

    context "on course -" do
      before do
        @environment = FactoryGirl.create(:environment, :owner => @env_admin)
      end

      context "member" do
        before do
          @ability = Ability.new(@member)
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
        end

        it "cannot create a course" do
          course = FactoryGirl.build(:course,:owner => @environment.owner,
                                 :environment => @environment)
          FactoryGirl.create(:user_course_association, :course => course,
                  :user => @member, :role => :member,
                  :state => "approved")

          @ability.should_not be_able_to(:create, course)
        end

        it "cannot destroy a course" do
          course = FactoryGirl.build(:course,:owner => @environment.owner,
                                 :environment => @environment)
          FactoryGirl.create(:user_course_association, :course => course,
                  :user => @member, :role => :member,
                  :state => "approved")

          @ability.should_not be_able_to(:destroy, course)
        end

        it "accepts a course invitation" do
          course = FactoryGirl.create(:course, :owner => @env_admin,
                           :environment => @environment)
          course.invite(@member)
          @ability.should be_able_to(:accept, course)
        end

        it "denies a course invitation" do
          course = FactoryGirl.create(:course, :owner => @env_admin,
                           :environment => @environment)
          course.invite(@member)
          @ability.should be_able_to(:deny, course)
        end

        it "cannot invite users" do
          course = FactoryGirl.build(:course,:owner => @environment.owner,
                                 :environment => @environment)

          @ability.should_not be_able_to(:invite_members, course)
        end

        it "can preview a course" do
          course = FactoryGirl.create(:course, :environment => @environment)
          FactoryGirl.create(:user_course_association, :course => course,
                  :user => @member, :role => :member)
          @ability.should be_able_to(:preview, course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "environment admin" do
        before  do
          @ability = Ability.new(@env_admin)
          @course = FactoryGirl.build(:course, :owner => @env_admin,
                                 :environment => @environment)
        end

        it "creates a course"  do
          @ability.should be_able_to(:create, @course)
        end

        it "destroys his course" do
          @ability.should be_able_to(:destroy, @course)
        end

        it "destroys a strange course when he is a environment admin" do
          cur_user = FactoryGirl.create(:user)
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => cur_user, :role => :environment_admin)
          course = FactoryGirl.build(:course, :owner => cur_user,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end

        it "cannot destroy a course when he isn't a environment admin" do
          cur_user = FactoryGirl.create(:user)
          environment_out = FactoryGirl.create(:environment, :owner => cur_user)
          course = FactoryGirl.build(:course, :owner => cur_user,
                                 :environment => environment_out)
          @ability.should_not be_able_to(:destroy, course)
        end

        context "if plan is blocked" do
          before do
            @course = FactoryGirl.create(:course,:owner => @env_admin,
                              :environment => @environment)
            @plan = FactoryGirl.create(:active_package_plan, :billable => @course)
            @plan.block!
            @space = FactoryGirl.create(:space, :owner => @env_admin, :course => @course)
            @sub = FactoryGirl.create(:subject, :owner => @env_admin, :space => @space)
          end

          # Need Seminar factory
          it "can NOT upload multimedia"

          it "can create a Youtube seminar" do
            youtube = FactoryGirl.build(:seminar_youtube)
            lecture = FactoryGirl.create(:lecture, :owner => @env_admin,
                              :subject => @sub,
                              :lectureable => youtube)
            @ability.should be_able_to(:upload_multimedia, youtube)
          end

          # Need Myfile factory
          it "can NOT upload file"
        end

        it "can see reports" do
          @ability.should be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can access JSON reports" do
          @ability.should be_able_to(:teacher_participation_interaction,
                                     @course)
        end

        it "invites members" do
          @ability.should be_able_to(:invite_members, @course)
        end

        it "views not accepted invitations" do
          @ability.should be_able_to(:admin_manage_invitations, @course)
        end

        it "destroys invitations" do
          @ability.should be_able_to(:destroy_invitations, @course)
        end
      end

      context "teacher" do
        before do
          @ability = Ability.new(@teacher)
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          @course = FactoryGirl.create(:course,:owner => @environment.owner,
                                 :environment => @environment)
          FactoryGirl.create(:user_course_association, :course => @course,
                  :user => @teacher, :role => :teacher,
                  :state => "approved")
        end

        it "cannot create a course" do
          @ability.should_not be_able_to(:create, @course)
        end
        it "cannot destroy a course" do
          @ability.should_not be_able_to(:destroy, @course)
        end

        it "cannot invite members" do
          @ability.should_not be_able_to(:invite_members, @course)
        end

        it "cannot view not accepted invitations" do
          @ability.should_not be_able_to(:admin_manage_invitations, @course)
        end

        it "cannot destroy invitations" do
          @ability.should_not be_able_to(:destroy_invitations, @course)
        end

        it "can teach course" do
          @ability.should be_able_to(:teach, @course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "tutor" do
        before do
          @ability = Ability.new(@tutor)
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :tutor)
          @course = FactoryGirl.create(:course,:owner => @environment.owner,
                                 :environment => @environment)
          FactoryGirl.create(:user_course_association, :course => @course,
                  :user => @tutor, :role => :tutor,
                  :state => "approved")
        end
        it "cannot create a course" do
          @ability.should_not be_able_to(:create, @course)
        end
        it "cannot destroy a course" do
          @ability.should_not be_able_to(:destroy, @course)
        end

        it "cannot invite members" do
          @ability.should_not be_able_to(:invite_members, @course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "redu admin" do
        before  do
          @ability = Ability.new(@redu_admin)
        end
        it "creates a course"  do
          course = FactoryGirl.build(:course, :owner => @redu_admin,
                                 :environment => @environment)
          @ability.should be_able_to(:create, course)
        end
        it "destroys his course" do
          course = FactoryGirl.build(:course, :owner => @redu_admin,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end
        it "destroys any course" do
          course = FactoryGirl.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end

        it "can see reports" do
          course = FactoryGirl.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:teacher_participation_report,
                                     course)
        end

        it "can access JSON reports" do
          course = FactoryGirl.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:teacher_participation_interaction,
                                     course)
        end
      end

      context "strange" do
        before do
          @strange = FactoryGirl.create(:user)
          @ability = Ability.new(@strange)
        end

        it "can preview a course" do
          course = FactoryGirl.create(:course, :environment => @environment)
          @ability.should be_able_to(:preview, course)
        end
      end
    end

    context "on space -" do
      before do
        @environment = FactoryGirl.create(:environment, :owner => @env_admin)
        @course = FactoryGirl.create(:course, :owner => @env_admin,
                          :environment => @environment)
        @space = FactoryGirl.create(:space, :course => @course)
      end
      context "member" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          FactoryGirl.create(:user_course_association, :course => @course,
                  :user => @member, :role => :member)
          FactoryGirl.create(:user_space_association, :space => @space,
                  :user => @member, :role => :member)
          @ability = Ability.new(@member)
        end

        it "cannot create a space" do
          @ability.should_not be_able_to(:create, FactoryGirl.create(:space,
                                                          :owner => @member,
                                                          :course => @course))
        end

        it "cannot destroy a space" do
          @ability.should_not be_able_to(:destroy, FactoryGirl.create(:space,
                                                           :owner => @member,
                                                           :course => @course))
        end

        it "can use students_endless on a space" do
          @ability.should be_able_to(:students_endless, @space)
        end

        it "can preview a space" do
          @ability.should be_able_to(:preview, @space)
        end

        it "can't see subject participation report" do
          @ability.should_not be_able_to(:subject_participation_report,
                                          @space)
        end

        it "can't see lecture participation report" do
          @ability.should_not be_able_to(:lecture_participation_report,
                                          @space)
        end

        it "can't see students participation report" do
          @ability.should_not be_able_to(:students_participation_report,
                                          @space)
        end
        it "cannot create a subject"
        it "cannot destroy any subject"
        it "cannot create a lecture"
        it "cannot destroy any lecture"
        it "cannot upload a file"
        it "cannot destroy any file"

        context "member posts on wall" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @member,
                                :statusable => @space)

            @answer_activity = FactoryGirl.create(:answer,
                                       :statusable => @activity,
                                       :in_response_to => @activity)

            @strange_activity = FactoryGirl.create(:activity, :statusable => @space)

            @strange_answer = FactoryGirl.create(:answer,
                                      :statusable => @strange_activity,
                                      :in_response_to => @strange_activity)
          end

          it "can creates a post" do
            @ability.should be_able_to(:create, @activity)
          end

          it "can destroy a post" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "can destroy answers from your posts" do
            @ability.should be_able_to(:destroy, @answer_activity)
          end

          it "can't destroy posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_activity)
          end

          it "can't destroy answers for posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_answer)
          end
        end
      end

      context "teacher" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          FactoryGirl.create(:user_course_association, :course => @course,
                  :user => @teacher, :role => :teacher)
          @space = FactoryGirl.create(:space, :owner => @teacher,
                           :course => @course)
          @ability = Ability.new(@teacher)
        end
        it "creates a space" do
          @ability.should be_able_to(:create, @space)
        end
        it "destroys his own space" do
          @ability.should be_able_to(:destroy, @space)
        end
        it "cannot destroy a strange space where he is a teacher" do
          environment1 = FactoryGirl.create(:environment)
          course1 = FactoryGirl.build(:course, :owner => environment1.owner,
                                  :environment => environment1)
          space1 = FactoryGirl.build(:space, :owner => @teacher,
                                 :course => course1)
          @ability.should_not be_able_to(:destroy, space1)
        end

        it "can't see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can't see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can't see studenst participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        context "manage posts" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @member,
                                :statusable => @space)

            @answer = FactoryGirl.create(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "tutor" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :member)
          FactoryGirl.create(:user_course_association, :course => @course,
                  :user => @tutor, :role => :member)
          @ability = Ability.new(@tutor)
        end

        it "cannot create a space" do
          @ability.should_not be_able_to(:create, FactoryGirl.create(:space,
                                                          :owner => @tutor,
                                                          :course => @course))
        end
        it "cannot destroy a space" do
          @ability.should_not be_able_to(:destroy, FactoryGirl.create(:space,
                                                           :owner => @tutor,
                                                           :course => @course))
        end

        it "can't see subject participation report" do
          @ability.should_not be_able_to(:subject_participation_report,
                                          @space)
        end

        it "can't see lecture participation report" do
          @ability.should_not be_able_to(:lecture_participation_report,
                                          @space)
        end

        it "can't see students participation report" do
          @ability.should_not be_able_to(:students_participation_report,
                                          @space)
        end

        it "cannot create a subject"
        it "cannot destroy any subject"
        it "cannot create a lecture"
        it "cannot destroy any lecture"
        it "cannot upload a file"
        it "cannot destroy any file"
        it "crates a post"
      end

      context "environment admin" do
        before do
          @ability = Ability.new(@env_admin)
          @space = FactoryGirl.create(:space, :owner => @env_admin,
                          :course => @course)
        end

        it "creates a space" do
          @ability.should be_able_to(:create, @space)
        end
        it "destroys a space" do
          @ability.should be_able_to(:destroy, @space)
        end

        it "can see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can see students participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        context "manage posts" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @env_admin,
                                :statusable => @space)

            @answer = FactoryGirl.create(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end
          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "redu admin" do
        before do
          @ability = Ability.new(@redu_admin)
          @space = FactoryGirl.create(:space, :owner => @env_admin,
                          :course => @course)
        end

        it "read a space" do
          @ability.should be_able_to(:read, @space)
        end

        it "manage a space" do
          @ability.should be_able_to(:manage, @space)
        end

        it "creates a space" do
          space = FactoryGirl.create(:space, :owner => @redu_admin,
                          :course => @course)
          @ability.should be_able_to(:create, space)
        end
        it "destroys a space" do
          @ability.should be_able_to(:destroy, @space)
        end

        it "can see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can see students participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "strange" do
        before do
          @strange = FactoryGirl.create(:user)
          @ability = Ability.new(@strange)
        end

        it "can NOT preview a space" do
          space = FactoryGirl.create(:space, :course => @course)
          @ability.should_not be_able_to(:preview, space)
        end
      end
    end

    context "on subject" do
      before do
        @environment = FactoryGirl.create(:environment, :owner => @env_admin)
        @course = FactoryGirl.create(:course, :owner => @env_admin,
                          :environment => @environment)
        @space = FactoryGirl.create(:space, :owner => @env_admin, :course => @course)
        @subject = FactoryGirl.create(:subject, :owner => @env_admin, :space => @space)

        @lecture_page = FactoryGirl.create(:lecture, :subject => @subject,
                                :lectureable => FactoryGirl.create(:page))
        @lecture_canvas = FactoryGirl.create(:lecture, :subject => @subject,
                                :lectureable => FactoryGirl.create(:canvas))
        @lecture_exercise = FactoryGirl.create(:lecture, :subject => @subject,
                                    :lectureable => FactoryGirl.create(:complete_exercise))
        @lecture_seminar = FactoryGirl.create(:lecture, :subject => @subject,
                                   :lectureable => FactoryGirl.create(:seminar_youtube))
        @lecture_document = FactoryGirl.create(:lecture, :subject => @subject,
                                    :lectureable => FactoryGirl.create(:document))

        @course.join @teacher, Role[:teacher]
        @course.join @tutor, Role[:tutor]
        @course.join @member, Role[:member]
      end

      context "environment_admin" do
        before do
          @ability = Ability.new(@env_admin)
        end

        context "can manage all kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should be_able_to(:manage, @lecture_document)
          end
        end

        context "can update many kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:update, @lecture_page)
          end

          it "(exercise)" do
            @ability.should be_able_to(:update, @lecture_exercise)
          end
        end

        context "can manage posts" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @member,
                                :statusable => @lecture_page)

            @answer = FactoryGirl.create(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end


        context "can NOT update many kinds of lectures" do
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end

          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end

          it "(exercise) with that was already answered" do
            FactoryGirl.create(:finalized_result, :exercise => @lecture_exercise.lectureable)
            @lecture_exercise.lectureable.reload
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
        end
      end

      context "teacher" do
        before do
          @ability = Ability.new(@teacher)
        end

        context "can manage all kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should be_able_to(:manage, @lecture_document)
          end
          it "(canvas)" do
            @ability.should be_able_to(:manage, @lecture_canvas)
          end
        end

        context "can update many kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:update, @lecture_page)
          end

          it "(exercise)" do
            @ability.should be_able_to(:update, @lecture_exercise)
          end
        end

        context "when lecture type canvas" do
          it "cannot update" do
            @ability.should_not be_able_to(:update, @lecture_canvas)
          end
        end

        context "can manage posts" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @member,
                                :statusable => @lecture_page)

            @answer = FactoryGirl.create(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        context "can NOT update many kinds of lectures" do
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end

      context "tutor" do
        before do
          @ability = Ability.new(@tutor)
        end

        context "can NOT manage all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:manage, @lecture_document)
          end
        end

        context "can NOT update all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:update, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end

      context "member" do
        before do
          @ability = Ability.new(@member)
        end

        context "can NOT manage all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:manage, @lecture_document)
          end
        end

        context "member posts on wall" do
          before do
            @activity = FactoryGirl.create(:activity,
                                :user => @member,
                                :statusable => @lecture_document)

            @help = FactoryGirl.create(:help,
                            :user => @member,
                            :statusable => @lecture_document)

            @answer_activity = FactoryGirl.create(:answer,
                                       :statusable => @activity,
                                       :in_response_to => @activity)

            @answer_help = FactoryGirl.create(:answer,
                                   :statusable => @help,
                                   :in_response_to => @help)


            @strange_activity = FactoryGirl.create(:activity,
                                        :statusable => @lecture_document)

            @strange_help = FactoryGirl.create(:help,
                                    :statusable => @lecture_document)

            @strange_answer = FactoryGirl.create(:answer,
                                      :statusable => @strange_activity,
                                      :in_response_to => @strange_activity)
          end

          it "can creates a post" do
            @ability.should be_able_to(:create, @activity)
            @ability.should be_able_to(:create, @help)
          end

          it "can destroy a post" do
            @ability.should be_able_to(:destroy, @activity)
            @ability.should be_able_to(:destroy, @help)
          end

          it "can destroy answers from your posts" do
            @ability.should be_able_to(:destroy, @answer_activity)
            @ability.should be_able_to(:destroy, @answer_help)
          end

          it "can't destroy posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_activity)
            @ability.should_not be_able_to(:destroy, @strange_help)
          end

          it "can't destroy answers for posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_answer)
          end
        end

        context "can NOT update all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:update, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end
    end

    context "on plans" do
      context "on any plan" do
        before do
          @plan = FactoryGirl.create(:plan)
          @ability = Ability.new(@plan.user)
        end

        context "blocked" do
          before do
            @plan.update_attribute(:state, "blocked")
          end

          it "can NOT be migrated" do
            @ability.should_not be_able_to(:migrate, @plan)
          end
        end

        context "migrated" do
          before do
            @plan.update_attribute(:state, "migrated")
          end

          it "can not be migrated" do
            @ability.should_not be_able_to(:migrate, @plan)
          end
        end
      end

      context "on package_plan" do
        before do
          @package_plan = FactoryGirl.create(:active_package_plan)
        end

        context "the owner" do
          before do
            @ability = Ability.new(@package_plan.user)
          end

          it "read its own package_plan" do
            @ability.should be_able_to(:read, @package_plan)
          end

          it "manages its own package_plan" do
            @ability.should be_able_to(:manage, @package_plan)
          end

          it "migrates its own package_plan" do
            @ability.should be_able_to(:migrate, @package_plan)
          end
        end

        context "the strange" do
          before do
            strange = FactoryGirl.create(:user)
            @ability = Ability.new(strange)
          end

          it "can NOT read others package_plans" do
            @ability.should_not be_able_to(:read, @package_plan)
          end

          it "can NOT manage others package_plans" do
            @ability.should_not be_able_to(:manage, @package_plan)
          end

          it "can NOT migrate others package_plans" do
            @ability.should_not be_able_to(:migrate, @package_plan)
          end
        end
      end
    end

  end

  context "on user -" do
    before do
      @user = FactoryGirl.create(:user)
      @user_ability = Ability.new(@user)
    end

    context "when friends" do
      before do
        @my_friend = FactoryGirl.create(:user)
        @my_friend_ability = Ability.new(@my_friend)

        friendship1, status = @user.be_friends_with(@my_friend)
        friendship2, status = @my_friend.be_friends_with(@user)
        friendship1.accept!
        friendship2.accept!
      end

      it "should read each other" do
        @user_ability.should be_able_to(:read, @my_friend)
        @my_friend_ability.should be_able_to(:read, @user)
      end

      it "should not manage each other" do
        @user_ability.should_not be_able_to(:manage, @my_friend)
        @my_friend_ability.should_not be_able_to(:manage, @user)
      end

      it "should send message to other" do
        @user_ability.should be_able_to(:send_message, @my_friend)
        @my_friend_ability.should be_able_to(:send_message, @user)
      end
    end

    context "when they are not friends" do
      before do
        @not_my_friend = FactoryGirl.create(:user)
        @not_my_friend_ability = Ability.new(@not_my_friend)
      end


      it "should not send message each other" do
        @user_ability.should_not be_able_to(:send_message, @not_my_friend)
        @not_my_friend_ability.should_not be_able_to(:send_message, @user)
      end
    end

    context "when user privacy" do
      context "let everyone see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:public]
        end

        context "and they are friends," do
          before do
            @my_friend = FactoryGirl.create(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = FactoryGirl.create(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can view user's statuses" do
            @someone_ability.should be_able_to(:view_mural, @user)
          end
        end
      end

      context "let ONLY friends see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:friends]
        end

        context "and they are friends," do
          before do
            @my_friend = FactoryGirl.create(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = FactoryGirl.create(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can NOT view user's statuses" do
            @someone_ability.should_not be_able_to(:view_mural, @user)
          end
        end
      end
    end

    context "when experiences" do
      before do
        @user_experience = FactoryGirl.create(:experience, :user => @user)
        @other_experience = FactoryGirl.create(:experience)
      end
      it "manages its own experiences" do
        @user_ability.should be_able_to(:manage, @user_experience)
      end

      it "can NOT manage other experiences" do
        @user_ability.should_not be_able_to(:manage, @other_experience)
      end
    end

    context "when educations" do
      before do
        @user_education = FactoryGirl.create(:education, :user => @user)
        @other_education = FactoryGirl.create(:education)
      end
      it "manages its own educations" do
        @user_ability.should be_able_to(:manage, @user_education)
      end

      it "can NOT manage other educations" do
        @user_ability.should_not be_able_to(:manage, @other_education)
      end
    end

    it "manages itself" do
      @user_ability.should be_able_to(:manage, @user)
    end

    it "inform that itself is online" do
      @user_ability.should be_able_to(:online, @user)
    end

    context "manages its own statuses" do
      it "when activy" do
        status = FactoryGirl.create(:activity, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end

      it "when answer" do
        status = FactoryGirl.create(:answer, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end

      it "when help" do
        status = FactoryGirl.create(:help, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end

      it "should be able to manage even when there is UserStatusAssociation" do
        status = FactoryGirl.create(:help, :user => @user)
        Status.associate_with(status, [@user])
        @user_ability.should be_able_to(:manage, status)
      end
    end

    context "reading statuses" do
      it "should be able to read if has UserStatusAssociation" do
        status = FactoryGirl.create(:activity)
        Status.associate_with(status, [@user])
        @user_ability.should be_able_to(:read, status)
      end
    end

    context "reading status answer" do
      it "should be able to read a answer when its status is readab;e" do
        status = FactoryGirl.create(:activity)
        Status.associate_with(status, [@user])
        someone = FactoryGirl.create(:user)
        answer = status.respond(FactoryGirl.attributes_for(:answer), someone)

        @user_ability.should be_able_to(:read, answer)
      end
    end

    context "when destroying user" do
      before do
        @other = FactoryGirl.create(:user)
      end
      it "can NOT destroy others user" do
        @user_ability.should_not be_able_to(:destroy, @other)
      end

      it "can destroy its own user" do
        @user_ability.should be_able_to(:destroy, @user)
      end
    end

    context "when seeing my wall" do
      before do
        @other = FactoryGirl.create(:user)
      end

      it "others can NOT access my wall" do
        @user_ability.should_not be_able_to(:my_wall, @other)
      end

      it "can access my wall" do
        @user_ability.should be_able_to(:my_wall, @user)
      end
    end

    context "when manage invitations" do
      before do
        @bastard = FactoryGirl.create(:user,
                           :first_name => 'Jhon',
                           :last_name => 'Snow')
        @bastard_ability = Ability.new(@bastard)
        @bastard_invitation = Invitation.invite(:user => @bastard,
                                                :hostable => @bastard,
                                                :email => 'mail@teste.com')

        @my_invitation = Invitation.invite(:user => @user,
                                           :hostable => @user,
                                           :email => 'mail@teste.com')
      end

      it "others can't manage my invitations" do
        @bastard_ability.should_not be_able_to(:manage, @my_invitation)
      end

      it "can destroy invitation" do
        @user_ability.should be_able_to(:destroy_invitations, @my_invitation)
      end

      it "can resend invitation email" do
        @user_ability.should be_able_to(:resend_email, @my_invitation)
      end
    end
  end

  context "on Result" do
    before do
      @space = FactoryGirl.create(:space)
      @subject = FactoryGirl.create(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = FactoryGirl.create(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => FactoryGirl.create(:complete_exercise))
      @exercise = @lecture.lectureable

      @member = FactoryGirl.create(:user)
      @other_member = FactoryGirl.create(:user)
      @teacher = FactoryGirl.create(:user)
      @tutor = FactoryGirl.create(:user)
      @external = FactoryGirl.create(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

    context "when teacher" do
      let(:ability) { Ability.new(@teacher) }
      let(:result) { @exercise.start_for(@member) }

      it "should be able to manage members results" do
        ability.should be_able_to(:manage, result)
      end

      it "should not be able to manage results from another space" do
        space = FactoryGirl.create(:space)
        subj = FactoryGirl.create(:subject, :owner => space.owner,
                       :space => space, :finalized => true,
                       :visible => true)
        lecture = FactoryGirl.create(:lecture, :subject => subj, :owner => space.owner,
                          :lectureable => FactoryGirl.create(:complete_exercise))
        exercise = lecture.lectureable
        space.course.join(@member)
        new_result = exercise.start_for(@member)

        ability.should_not be_able_to(:manage, new_result)
      end
    end

    context "when member" do
      let(:ability) { Ability.new(@member) }
      let(:own_result) { @exercise.start_for(@member) }
      let(:other_result) { @exercise.start_for(@other_member) }

      it "should be able to read own result" do
        ability.should be_able_to(:read, own_result)
      end

      it "should be able to create" do
        ability.should be_able_to(:create, Result)
      end

      it "should be able to update" do
        ability.should be_able_to(:update, own_result)
      end

      it "should not be able to update if finalized" do
        @exercise.start_for(@member)
        result = @exercise.finalize_for(@member)
        ability.should_not be_able_to(:update, result)
      end

      it "should not be able to update a strange result" do
        ability.should_not be_able_to(:update, other_result)
      end

      it "should not be able to read a strange result" do
        ability.should_not be_able_to(:read, other_result)
      end

      it "should not be able to read the another member result" do
        ability.should_not be_able_to(:read, other_result)
      end
    end

    context "when strange" do
      let(:ability) { Ability.new(@strange) }
      let(:member_result) { @exercise.start_for(@member) }

      it "should not be able to read" do
        ability.should_not be_able_to(:read, member_result)
      end
    end
  end

  context "on Question" do
   before do
      @space = FactoryGirl.create(:space)
      @subject = FactoryGirl.create(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = FactoryGirl.create(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => FactoryGirl.create(:complete_exercise))
      @exercise = @lecture.lectureable
      @questions = @exercise.questions

      @member = FactoryGirl.create(:user)
      @other_member = FactoryGirl.create(:user)
      @teacher = FactoryGirl.create(:user)
      @tutor = FactoryGirl.create(:user)
      @external = FactoryGirl.create(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

    context "when member" do
      let(:ability) { Ability.new(@member) }
      it "should be able to read" do
        ability.should be_able_to(:read, @questions.first)
      end
    end

    context "when teacher" do
      let(:ability) { Ability.new(@teacher) }
      it "should be able to read" do
        ability.should be_able_to(:read, @questions.first)
      end
    end

    context "when strange" do
      let(:ability) { Ability.new(@strange) }

      it "should not be able to read" do
        ability.should_not be_able_to(:read, @questions.first)
      end
    end
  end

  context "on Exercise" do
   before do
      @space = FactoryGirl.create(:space)
      @subject = FactoryGirl.create(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = FactoryGirl.create(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => FactoryGirl.create(:complete_exercise))
      @exercise = @lecture.lectureable
      @questions = @exercise.questions

      @member = FactoryGirl.create(:user)
      @other_member = FactoryGirl.create(:user)
      @teacher = FactoryGirl.create(:user)
      @tutor = FactoryGirl.create(:user)
      @external = FactoryGirl.create(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

   context "when teacher" do
     let(:ability) { Ability.new(@teacher) }
     it "should not be able to update if there are finalized results" do
       @exercise.start_for(@member)
       @exercise.finalize_for(@member)
       ability.should_not be_able_to(:manage, @exercise)
     end

     it "should be able to update if there arent finalized results" do
       @exercise.start_for(@member)
       ability.should be_able_to(:manage, @lecture)
     end

     it "should be able to update if there arent results at all" do
       ability.should be_able_to(:manage, @lecture)
     end
   end
  end

  context "on Canvas" do
    before do
      env = FactoryGirl.create(:complete_environment)
      @course = env.courses.first
      space = @course.spaces.first
      sub = FactoryGirl.create(:subject, :owner => space.owner,
                    :space => space, :finalized => true,
                    :visible => true)

      @canvas = FactoryGirl.create(:canvas, :user => @course.owner)
      FactoryGirl.create(:lecture, :subject => sub,
              :owner => space.owner, :lectureable => @canvas)
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(user) }

    context "when member" do
      before do
        @course.join(user)
      end

      it "should be able to read" do
        ability.should be_able_to :read, @canvas
      end
    end

    context "when outsider" do
      it "should not be able to read" do
        ability.should_not be_able_to :read, @canvas
      end
    end
  end

  context "client applications" do
    let(:user) { FactoryGirl.create(:user) }
    let(:client_application) { ClientApplication.new }
    let(:ability) { Ability.new(user) }
    let(:redu_admin) {FactoryGirl.create(:user, :role => :admin)}
    let(:admin_abilty) {Ability.new(redu_admin)}

    context "when application owner" do
      before do
        client_application.user = user
      end

      it "should be able to manage own application" do
        ability.should be_able_to(:manage, client_application)
      end
    end

    context "when not owner" do
      before do
        client_application.user = redu_admin
      end

      it "should no be able to manage others application" do
        ability.should_not be_able_to(:manage, client_application)
      end
    end
  end

  context "a user with a blocked association" do
    before do
      @user = FactoryGirl.create(:user)
      @ability = Ability.new(@user)

      @admin = FactoryGirl.create(:user, :role => :admin)
      @ability_admin = Ability.new(@admin)
    end

    context 'in an environment' do
      before do
        @environment = FactoryGirl.create(:environment, :blocked => true)
        FactoryGirl.create(:user_environment_association, :environment => @environment,
                :user => @user)
      end

      it 'can not read the environment' do
        @ability.should_not be_able_to(:read, @environment)
      end

      context "as redu admin" do
        before do
          FactoryGirl.create(:user_environment_association, :environment => @environment,
                  :user => @admin)
        end

        it "can read the environment" do
          @ability_admin.should be_able_to(:read, @environment)
        end

        it "can manage the environment" do
          @ability_admin.should be_able_to(:manage, @environment)
        end
      end
    end

    context 'in a course' do
      before do
        @course = FactoryGirl.create(:course, :blocked => true)
        FactoryGirl.create(:user_course_association, :course => @course, :user => @user).
          approve!
      end

      it 'can not read the course' do
        @ability.should_not be_able_to(:read, @course)
      end

      context "as redu admin" do
        before do
          FactoryGirl.create(:user_course_association, :course => @course, :user => @admin).
            approve!
        end

        it "can read the course" do
          @ability_admin.should be_able_to(:read, @course)
        end

        it "can manage de course" do
          @ability_admin.should be_able_to(:manage, @course)
        end
      end
    end

    context 'in a space' do
      before do
        @space = FactoryGirl.create(:space, :blocked => true)
        FactoryGirl.create(:user_space_association, :space => @space, :user => @user)
      end

      it 'can not read the space' do
        @ability.should_not be_able_to(:read, @space)
      end

      context "as redu admin" do
        before do
          FactoryGirl.create(:user_space_association, :space => @space, :user => @admin)
        end

        it "can read the space" do
          @ability_admin.should be_able_to(:read, @space)
        end

        it "can manage the space" do
          @ability_admin.should be_able_to(:manage, @space)
        end
      end
    end

    context 'in a subject' do
      before do
        @subject = FactoryGirl.create(:subject, :blocked => true)
        FactoryGirl.create(:enrollment, :subject => @subject, :user => @user)
      end

      it 'can not read the subject' do
        @ability.should_not be_able_to(:read, @subject)
      end

      context "as redu admin" do
        before do
          FactoryGirl.create(:enrollment, :subject => @subject, :user => @admin)
        end

        it "can read the subject" do
          @ability_admin.should be_able_to(:read, @subject)
        end

        it "can manage the subject" do
          @ability_admin.should be_able_to(:manage, @subject)
        end
      end
    end

    context 'in a lecture' do
      before do
        @lecture = FactoryGirl.create(:lecture, :blocked => true)
        FactoryGirl.create(:enrollment, :subject => @lecture.subject, :user => @user)
      end

      it 'can not read the lecture' do
        @ability.should_not be_able_to(:read, @lecture)
      end

      context "as redu admin" do
        before do
          FactoryGirl.create(:enrollment, :subject => @lecture.subject, :user => @admin)
        end

        it "can read the lecture" do
          @ability_admin.should be_able_to(:read, @lecture)
        end

        it "can manage the lecture" do
          @ability_admin.should be_able_to(:manage, @lecture)
        end
      end
    end
  end

  context "when searching" do
    context "logged user" do
      let(:user) { FactoryGirl.create(:user) }

      it "should be able to perform searches" do
        Ability.new(user).should be_able_to :search, :all
      end
    end

    context "not logged user" do
      let(:user) { nil }

      it "should not be able to perform searches" do
        Ability.new(user).should_not be_able_to :search, :all
      end
    end
  end
end
