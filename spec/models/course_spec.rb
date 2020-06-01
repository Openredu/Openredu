# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do

  before(:each) do
    @environment_owner = FactoryGirl.create(:user)
    @environment = FactoryGirl.create(:environment, :owner => @environment_owner)
  end

  subject { FactoryGirl.create(:course, :owner => @environment_owner,
                    :environment => @environment) }

  it { should belong_to :environment }
  it { should belong_to :owner }

  it { should have_many(:spaces).dependent :destroy }
  it { should have_many(:user_course_associations).dependent :destroy }
  it { should have_many(:user_course_invitations).dependent :destroy }
  it { should have_many(:users).through :user_course_associations }
  it { should have_many(:approved_users).through :user_course_associations }
  it { should have_many(:pending_users).through :user_course_associations }
  it { should have_many(:administrators).through :user_course_associations }
  it { should have_many(:teachers).through :user_course_associations }
  it { should have_many(:tutors).through :user_course_associations }
  it { should have_many(:students).through :user_course_associations }
  it { should have_many(:teachers_and_tutors).through :user_course_associations }

  it { should have_and_belong_to_many :audiences }
  it { should have_one(:quota).dependent(:destroy) }

  it { should have_many :logs }
  it { should have_many :statuses }

  it { should validate_presence_of :name }
  it { should validate_presence_of :path }
  #FIXME Não funciona por problemas de tradução (ver bug #17)
  xit { should validate_uniqueness_of(:name).scoped_to :environment_id}
  xit { should validate_uniqueness_of(:path).scoped_to :environment_id}
  it { should ensure_length_of(:name).is_at_most 60 }
  it { should ensure_length_of(:description).is_at_most 250 }

  it { should allow_value("test-medio").for(:path)}

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :published }
  it { should_not allow_mass_assignment_of :environment }

  it { Course.new.should respond_to(:notify).with(1).argument}


  context "validations" do
    it "ensure format for path: doesn't accept no ascii" do
      subject.path = "teste-médio"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

    it "ensure format for path: doesn't accept space" do
      subject.path = "teste medio"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

    it "ensure format for path: doesn't accept '?'" do
      subject.path = "teste-medio?"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

  end

  context "callbacks" do
    it "creates an approved association with its owner" do
      subject.owner.should == subject.users.last
      subject.owner.user_course_associations.last.state.should == 'approved'
    end

    it "creates a course association with all environment admins if it already has an environment" do
      e = FactoryGirl.create(:environment)
      users = (1..4).collect { FactoryGirl.create(:user) }
      e.users << [users[0], users[1], users[2]]

      users[0].user_environment_associations.last.update_attribute(:role, Role[:environment_admin])
      users[1].user_environment_associations.last.update_attribute(:role, Role[:environment_admin])

      c = FactoryGirl.create(:course, :owner => users[1], :environment => e)
      c.users.to_set.should == e.administrators.to_set
    end

    it "does NOT create a course association with all environment admins if it does NOT have an environment" do
      expect {
        subject = FactoryGirl.create(:course, :environment => nil)
      }.to_not change(UserCourseAssociation, :count)
    end
  end

  context "finders" do
    it "retrieves all courses of an specified environment" do
      course2 = FactoryGirl.create(:course, :environment => subject.environment)
      course3 = FactoryGirl.create(:course)

      Course.of_environment(subject.environment).to_set.
        should == [course2, subject].to_set
    end

    it "retrieves a course by its path" do
      Course.find(subject.path).should == subject
    end

    it "retrieves all approved users" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      subject.subscription_type = 2 # Com moderação
      subject.save

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])

      users[0..2].collect { |u| u.user_course_associations.last.approve! }

      subject.approved_users.to_set.
        should == (users[0..2] << subject.owner <<
          subject.environment.owner).to_set
    end

    it "retrieves all pending users" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      subject.subscription_type = 2 # Com moderação
      subject.save

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])

      users[0..2].collect { |u| u.user_course_associations.last.approve! }

      subject.pending_users.should == users[3..4]
    end

    it "retrieves all administrators" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])
      subject.administrators.to_set.
        should == [users[0], users[1], subject.owner, subject.environment.owner].to_set
    end

    it "retrieves all teachers" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      FactoryGirl.create(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      FactoryGirl.create(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      FactoryGirl.create(:user_course_association, :user => users[2],
              :course => subject, :role => :teacher)
      FactoryGirl.create(:user_course_association, :user => users[3],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.teachers.to_set.
        should == [users[1], users[2]].to_set
    end

    it "retrieves all tutors" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      FactoryGirl.create(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      FactoryGirl.create(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      FactoryGirl.create(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[3],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.tutors.to_set.
        should == [users[2], users[3]].to_set
    end

    it "retrieves all teachers and tutors" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      FactoryGirl.create(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      FactoryGirl.create(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      FactoryGirl.create(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[3],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.teachers_and_tutors.to_set.
        should == [users[1], users[2], users[3]].to_set
    end

    it "retrieves all students" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      FactoryGirl.create(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      FactoryGirl.create(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      FactoryGirl.create(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor)
      FactoryGirl.create(:user_course_association, :user => users[3],
              :course => subject, :role => :member)
      FactoryGirl.create(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.students.to_set.
        should == [users[3], users[4]].to_set
    end

    it "retrieves new users from 1 week ago" do
      users = 5.times.inject([]) { |res, i| res << FactoryGirl.create(:user) }
      FactoryGirl.create(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin,
              :created_at => 2.weeks.ago,
              :updated_at => 2.weeks.ago)
      FactoryGirl.create(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher,
              :updated_at => 2.weeks.ago)
      FactoryGirl.create(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor,
              :updated_at => 2.weeks.ago)
      FactoryGirl.create(:user_course_association, :user => users[3],
              :course => subject, :role => :member,
              :updated_at => 2.weeks.ago)
      FactoryGirl.create(:user_course_association, :user => users[4],
              :course => subject, :role => :member,
              :updated_at => 2.weeks.ago)

      subject.user_course_associations.update_all("state = 'approved'")

      subject.new_members.to_set.
        should == [@environment_owner].to_set
    end

    it "retrieves all courses in one of specified categories" do
      audiences = (1..4).collect { FactoryGirl.create(:audience) }
      courses = (1..4).collect { FactoryGirl.create(:course) }

      courses[0].audiences << audiences[0] << audiences[1] << audiences[2]
      courses[1].audiences << audiences[0]
      courses[2].audiences << audiences[2]
      courses[3].audiences << audiences[3]

      Course.with_audiences([audiences[0].id, audiences[2].id]).
        should == [courses[0], courses[1], courses[2]]
    end

    context "retrieves all courses where the specified user" do
      before do
        @user = FactoryGirl.create(:user)
        @courses = (0..6).collect { FactoryGirl.create(:course) }
        @courses[0].join @user
        @courses[1].join @user
        @courses[2].join @user, Role[:tutor]
        @courses[3].join @user, Role[:teacher]
        @courses[4].join @user, Role[:environment_admin]
        UserCourseAssociation.create(
          :course_id => @courses[6].id, :user_id => @user.id,
          :role => Role[:member])


        @courses[5].join FactoryGirl.create(:user)
        @courses[5].join FactoryGirl.create(:user), Role[:tutor]
        @courses[5].join FactoryGirl.create(:user), Role[:teacher]
        @courses[5].join FactoryGirl.create(:user), Role[:environment_admin]
      end

      it "is a administrator" do
        Course.user_behave_as_administrator(@user).should == [@courses[4]]
      end
      it "is a teacher" do
        Course.user_behave_as_teacher(@user).should == [@courses[3]]
      end
      it "is a tutor" do
        Course.user_behave_as_tutor(@user).should == [@courses[2]]
      end
      it "is a student" do
        Course.user_behave_as_student(@user).should == @courses[0..1]
      end
    end
  end

  it "changes a user role" do
    user = FactoryGirl.create(:user)
    subject.users << user
    subject.save

    expect {
      subject.change_role(user, Role[:tutor])
    }.to change {
      subject.user_course_associations.last.role }.to(Role[:tutor])

  end

  context "when joining an user" do
    before do
      @space = FactoryGirl.create(:space, :course => subject)
      @subj = FactoryGirl.create(:subject, :space => @space,
                              :owner => subject.owner,
                              :finalized => true)
      @user = FactoryGirl.create(:user)
      subject.reload
    end

    context "without a role" do
      before do
        subject.join(@user)
      end

      it "creates environment association" do
        assoc = @user.get_association_with(@environment)
        assoc.should_not be_nil
        assoc.role.should be_member
      end

      it "creates course association" do
        assoc = @user.get_association_with(subject)
        assoc.should_not be_nil
        assoc.role.should be_member
      end

      it "creates space association" do
        assoc = @user.get_association_with(@space)
        assoc.should_not be_nil
        assoc.role.should be_member
      end

      it "enrolls the user" do
        assoc = @user.get_association_with(@subj)
        assoc.should_not be_nil
        assoc.role.should be_member
      end
    end

    context "with a role" do
      before do
        subject.join(@user, Role[:environment_admin])
      end

      it "creates environment association" do
        assoc = @user.get_association_with(@environment)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "creates course association" do
        assoc = @user.get_association_with(subject)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "creates space association" do
        assoc = @user.get_association_with(@space)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "enrolls the user" do
        assoc = @user.get_association_with(@subj)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end
    end

    context "with user invited" do
      before do
        subject.invite(@user)
        @user.reload
      end

      it "should approve and create all hierarchy" do
        subject.join(@user)
        assoc = @user.get_association_with(subject)
        assoc.state.should == "approved"
      end
    end

    context "using VisClient" do
      it "should call VisClient.notify_delayed" do
        enrollment = FactoryGirl.create(:enrollment, :subject => @subj,
                                   :user => @user)
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "enrollment",
               [enrollment])
        subject.join(@user)
      end
    end
  end

  context "when force joining a user" do
    before  do
      @user = FactoryGirl.create(:user)
      @moderated_course = FactoryGirl.create(:course,  :owner => @environment_owner,
        :environment => @environment, :subscription_type => 0)
    end

    it "should join! uninvited user(subscription_type 0)" do
      @moderated_course.join!(@user)
      @user.get_association_with(@moderated_course).should be_approved
    end

    it "should join! on open courses(subscription_type 1)" do
      subject.join!(@user)
      @user.get_association_with(subject).should be_approved
    end

    it "should join! invited user (subscription_type 0)" do
      @moderated_course.join(@user)
      @user.get_association_with(@moderated_course).invite!
      @moderated_course.join!(@user)
      @user.get_association_with(@moderated_course).should be_approved
    end
  end

  context "removes a user (unjoin)" do
    before do
      @plan = FactoryGirl.create(:active_package_plan, :billable => @environment)
      @environment.create_quota
      @environment.reload
      @space = FactoryGirl.create(:space, :course => subject)
      @space_2 = FactoryGirl.create(:space, :course => subject)
      @sub = FactoryGirl.create(:complete_subject, :space => @space,
                     :owner => subject.owner)
      @sub_2 = FactoryGirl.create(:complete_subject, :space => @space_2,
                       :owner => subject.owner)
      @user = FactoryGirl.create(:user)
      subject.join @user
      subject.reload
    end

    it "removes a user from itself" do
      subject.unjoin @user
      subject.users.should_not include(@user)
    end

    it "removes a user from all spaces" do
      subject.unjoin @user
      @space.users.should_not include(@user)
      @space_2.users.should_not include(@user)
    end

    it "should invoke Subject.unenroll with all subjects" do
      subjects = [@sub, @sub_2]
      Subject.should_receive(:unenroll).with(subjects, @user)

      subject.unjoin @user
    end

    context "when user is enrolled with just one course" do
      it "removes the user from the environment" do
        expect {
          subject.unjoin @user
        }.to change(UserEnvironmentAssociation, :count).by(-1)
        @environment.users.should_not include(@user)
      end
    end

    context "when user is enrolled with more than one course" do
      before do
        @other_course = FactoryGirl.create(:course, :environment => @environment)
        @other_course.join @user
      end

      it "let the user as a member of the environment"  do
        expect {
          subject.unjoin @user
        }.to_not change(UserEnvironmentAssociation, :count)
        @environment.users.should include(@user)
      end
    end

    context 'when the user is with pending moderation' do
      before do
        @user_pending = FactoryGirl.create(:user)
        subject.update_attribute(:subscription_type, 2) # Com Moderação
        subject.join @user_pending
      end

      it 'dont raise an error' do
        expect {
          subject.unjoin @user_pending
        }.to_not raise_error
      end
    end
  end

  it "verifies if the user is waiting for approval" do
    user = FactoryGirl.create(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.join(user)

    subject.waiting_approval?(user).should be_true
  end

  it "verifies if the user has been rejected" do
    user = FactoryGirl.create(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.join(user)
    user.user_course_associations.last.reject!

    subject.rejected_participation?(user).should be_true
  end

  it "verifies if the course is waiting for user approval" do
    user = FactoryGirl.create(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.invite(user)

    subject.waiting_user_approval?(user).should be_true
  end

  context "when creating hierarchy associations" do
    before do
      @space = FactoryGirl.create(:space, :course => subject)
      subject.spaces << @space
      @user = FactoryGirl.create(:user)
    end

    it "creates hierarchy associations for a specified user" do
      subject.create_hierarchy_associations(@user)
      @user.user_environment_associations.last.environment.
        should == subject.environment
      @user.user_space_associations.last.space.should == @space
    end

    it "creates hierarchy associations for a specified user with a given role" do
      subject.create_hierarchy_associations(@user, Role[:tutor])
      @user.user_environment_associations.last.environment.
        should == subject.environment
      @user.user_space_associations.last.space.should == @space
      @user.user_environment_associations.last.role.should be_tutor
      @user.user_space_associations.last.role.should be_tutor
    end

    it "should not double create environment association" do
      expect {
        2.times do
          subject.create_hierarchy_associations(@user, Role[:tutor])
        end
      }.to change(UserEnvironmentAssociation, :count).by(1)
    end

    it "should not double create space association" do
      expect {
        2.times do
          subject.create_hierarchy_associations(@user, Role[:tutor])
        end
      }.to change(UserSpaceAssociation, :count).by(1)
    end
  end

  context "when inviting an user" do

    it "returns the association" do
      @incoming_user = FactoryGirl.create(:user)
      assoc = subject.invite(@incoming_user)
      assoc.should == @incoming_user.get_association_with(subject)
    end

    it "sets up the member Role as default" do
      @incoming_user = FactoryGirl.create(:user)
      assoc = subject.invite(@incoming_user)
      assoc.role.should be_member
    end

    context "when the user is not associated at all" do
      before do
        @incoming_user = FactoryGirl.create(:user)
        subject.invite(@incoming_user)
      end

      it "creates an association" do
        assoc = subject.user_course_associations.last
        assoc.user.should == @incoming_user
      end

      it "invites the user" do
        assoc = subject.user_course_associations.last
        assoc.should be_invited
      end
    end

    context "when the user is in moderation" do
      before do
        subject.update_attribute(:subscription_type, 0)

        @incoming_user = FactoryGirl.create(:user)
        subject.join(@incoming_user)
      end

      it "does not create a new association" do
        expect {
          subject.invite(@incoming_user)
        }.to_not change(UserCourseAssociation, :count)
      end

      it "changes his state to approved" do
          subject.invite(@incoming_user)
          @incoming_user.reload.get_association_with(subject).should be_approved
      end
    end

    context "when the user is already invited" do
      before do
        @incoming_user = FactoryGirl.create(:user)
        subject.invite(@incoming_user)
      end

      it "does not create a new association" do
        expect {
          subject.invite(@incoming_user)
        }.to_not change(UserCourseAssociation, :count)
      end
    end

    context "when the user is already approved" do
      before do
        @already_member = FactoryGirl.create(:user)
        subject.update_attribute(:subscription_type, 1)
        subject.join(@already_member)
      end

      it "does not change his state" do
        expect {
          subject.invite(@already_member)
        }.to_not change {
          @already_member.get_association_with(subject).state
        }
      end
    end

    context "and it is already invited" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        @already_invited = FactoryGirl.create(:user)
        @invitation = subject.invite @already_invited
      end

      it "does NOT change his state" do
        expect {
          subject.invite(@already_invited)
        }.to_not change {
          @already_invited.get_association_with(subject).state
        }
      end

      it "returns the same invitation" do
        invitation = subject.invite @already_invited
        invitation.should == @invitation
      end

      it "resends the e-mail invitation" do
        UserNotifier.deliveries = []

        invitation = subject.invite(@already_invited)
        UserNotifier.deliveries.should_not be_empty
        UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para realizar um curso a distância/
      end
    end

    context "by email" do
      before do
        @not_registered_email = "email@example.com"
      end

      it "returns the invitation"  do
        assoc = subject.invite_by_email(@not_registered_email)
        assoc.should == subject.user_course_invitations.reload.last

        u = FactoryGirl.create(:user)
        assoc = subject.invite_by_email(u.email)
        assoc.should == subject.user_course_associations.reload.last
      end

      context "when the email is not registered on Redu at all" do
        it "creates an email invitation" do
          expect {
            subject.invite_by_email(@not_registered_email)
          }.to change(UserCourseInvitation, :count).by(1)
        end
      end

      context "when the email is already invited" do
        before do
            subject.invite_by_email(@not_registered_email)
        end

        it "does NOT create a new invitation" do
          expect {
            subject.invite_by_email(@not_registered_email)
          }.to_not change(UserCourseInvitation, :count)
        end
      end

      context "when the email is already registered on Redu" do
        before do
          @registered_user = FactoryGirl.create(:user)
        end

        it "does NOT create an e-mail invitation" do
          expect {
            subject.invite_by_email(@registered_user.email)
          }.to_not change(UserCourseInvitation, :count)
        end

        it "creates an association" do
          subject.reload
          expect {
            subject.invite_by_email(@registered_user.email)
          }.to change(UserCourseAssociation, :count).by(1)
        end
      end

      context "and it is already invited" do
        before do
          UserNotifier.delivery_method = :test
          UserNotifier.perform_deliveries = true
          UserNotifier.deliveries = []

          @email_already_invited = "email@example.com"
          @invitation = subject.invite_by_email @email_already_invited
        end

        it "does NOT change his state" do
          expect {
            subject.invite_by_email @email_already_invited
          }.to_not change {
            @invitation.reload.state
          }
        end

        it "returns the same invitation" do
          invitation = subject.invite_by_email @email_already_invited
          invitation.should == @invitation
        end

        it "resends the e-mail invitation" do
          UserNotifier.deliveries = []

          invitation = subject.invite_by_email @email_already_invited
          UserNotifier.deliveries.should_not be_empty
          UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para realizar um curso a distância/
            UserNotifier.deliveries.last.body.should =~ /#{invitation.course.name}/
        end
      end
    end
  end

  context "when 3 or more people are enrolling to courses" do
    before do
      @users = 3.times.collect { FactoryGirl.create(:user) }

      ActiveRecord::Observer.with_observers(
        :user_course_association_observer,
        :log_observer,
        :status_observer) do
          @users.each { |user| subject.join(user) }
      end
      @course_compounds = CompoundLog.where(:statusable_id => subject.id)
    end

    it "should notify all users approved in course about compound log" do
      subject.approved_users.each do |user|
        StatusUserAssociation.where(
          :user_id => user.id,
          :status_id => @course_compounds.last.id).should_not be_empty
      end
    end
  end

  it "indicates if it invited users by email" do
    subject.invited?("email@example.com").should be_false

    subject.invite_by_email("email@example.com")
    subject.invited?("email@example.com").should be_true
  end

  it "doesnt accept ." do
    subject.path = "www.redu.com.br"
    subject.should_not be_valid
    subject.errors[:path].should_not be_empty
  end

  context "behaves like a billable" do
    before do
      users = 4.times.collect { FactoryGirl.create(:user) }

      FactoryGirl.create(:active_package_plan, :billable => subject, :user => subject.owner,
              :members_limit => 10)

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
    end

    it_should_behave_like "a billable" do
      let(:billable) { subject }
    end

    context "when verifying members limit and plan is on course" do
      before do
        # Sem moderação
        subject.subscription_type = 1
        (1..5).each { subject.join(FactoryGirl.create(:user)) }
      end

      context "and plan has members limit" do
        before do
          plan = Plan.from_preset(:free)
          plan.user = subject.owner
          plan.members_limit = 15
          subject.plan = plan
        end

        it "should permit entry" do
          subject.can_add_entry?.should be_true
        end

        it "should NOT permit entry" do
          (1..15).each { subject.join(FactoryGirl.create(:user)) }
          subject.can_add_entry?.should be_false
        end
      end

      context "and plan dones NOT have members limit" do
        before do
          plan = Plan.from_preset(:free, "LicensedPlan")
          plan.user = subject.owner
          subject.plan = plan
        end

        it "should permit entry" do
          subject.can_add_entry?.should be_true
        end

        it "should permit entry" do
          (1..15).each { subject.join(FactoryGirl.create(:user)) }
          subject.can_add_entry?.should be_true
        end
      end
    end

    context "when destroying" do
      let(:subject) { FactoryGirl.create(:course) }
      context "with an associated plan" do
        it "should persist environment attributes" do
          subject.plans = []
          plan = FactoryGirl.create(:active_package_plan, :billable => subject)

          subject.audit_billable_and_destroy
          plan.reload.billable_audit["name"].should == subject.name
          plan.reload.billable_audit["path"].should == subject.path
        end
      end

      context "withdout an associated plan" do
        it "should only destroy itself" do
          expect {
            subject.audit_billable_and_destroy
          }.to_not raise_error
        end
      end
    end
  end

  context "with a space marked for destruction" do
    it "should destroy associated space" do
      subject.spaces << \
        FactoryGirl.create(:space, :owner => subject.owner, :course => subject,
                :destroy_soon => true)
      subject.spaces.reload
      expect {
        subject.destroy
      }.to change(Space, :count).by(-1)
    end
  end

end
