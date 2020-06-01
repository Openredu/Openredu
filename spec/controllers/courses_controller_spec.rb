# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe CoursesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:environment) { FactoryGirl.create(:environment, owner: user) }
  let(:course) do
    FactoryGirl.create(:course, environment: environment, owner: user)
  end
  let(:space) { FactoryGirl.create(:space, course: course, owner: user) }
  let(:spaces) do
    FactoryGirl.create_list(:space, 2, course: course, owner: user)
  end
  let(:subjects) do
    spaces.map do |s|
      FactoryGirl.create_list(:subject, 2, space: s, owner: user, finalized: true)
    end.flatten
  end
  let(:users) { FactoryGirl.create_list(:user, 5).map { |u| course.join(u); u } }
  let(:locale_params) { { locale: "pt-BR" } }
  let(:course_params) { locale_params.merge(id: course.path) }
  let(:nested_course_params) do
    course_params.merge(environment_id: environment.path)
  end

  context "when creating a course for an existing environment" do
    let(:environment_params) { locale_params.merge(environment_id: environment.path) }
    let(:params) do
      environment_params.
        merge({ course: { name: "Redu", path: "redu", subscription_type: "1" },
                plan: "free" })
    end

    before { login_as user }

    context "POST create" do
      before do
        post :create, params
      end

      it "should create the course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should create the plan" do
        assigns[:course].plan.should_not be_nil
      end

      it "should assign the plan user to current_user" do
        assigns[:course].plan.user.should == user
      end

      it "should create the quota and computes it" do
        assigns[:course].quota.should_not be_nil
      end
    end

    context "POST create" do
      it "should be a professor_plus plan" do
        post :create, params
        assigns[:plan].name.should == "Professor Plus"
      end
    end
  end

  context "when updating a couse" do
    let(:params) do
      nested_course_params.merge({ course: { subscription_type: "1" }})
    end

    before do
      course.update_attribute(:subscription_type, 2)
      login_as user
    end

    it "should update a course" do
      post :update, params
      assigns[:course].should_not be_nil
      assigns[:course].should be_valid
    end

    context "POST update - updating a subscription_type to 1" do
      let!(:users) do
        FactoryGirl.create_list(:user, 5).map { |u| course.join(u); u }
      end

      it "should create associations with all members that are waiting" do
        post :update, params
        course.approved_users.to_set.should == (users << user).to_set
        course.pending_users.should == []
      end
    end
  end

  context "when moderating a course" do
    let!(:plan) { FactoryGirl.create(:plan, billable: course, user: course.owner) }

    before do
      course.update_attribute(:subscription_type, 2)
      course.create_quota
      login_as user
    end

    context "POST - rejecting members" do
      let(:params) do
        nested_course_params.
          merge({ member: { users[1].id.to_s => "reject",
                            users[2].id.to_s => "reject",
                            users[3].id.to_s => "approve"}})
      end

      before do
        post :moderate_members_requests, params
      end

      it "should assign course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should destroy association" do
        users[1].get_association_with(course).should be_nil
        users[2].get_association_with(course).should be_nil
        users[1].get_association_with(course.environment).should be_nil
        users[2].get_association_with(course.environment).should be_nil
        users[1].get_association_with(space).should be_nil
        users[2].get_association_with(space).should be_nil
        course.approved_users.should =~ [user, users[3]]
      end

      it "should not raise error when moderating again" do
        expect {
          post :moderate_members_requests, params
        }.to_not raise_error(AASM::InvalidTransition)
      end
    end

    context "POST - accepting member" do
      let(:params) do
        nested_course_params.merge({ member: { users[1].id.to_s => "approve",
                                      users[2].id.to_s => "approve"}})
      end

      before do
        post :moderate_members_requests, params
      end

      it "should assign course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should approve association" do
        course.approved_users.should =~ [users[1], users[2], user]
      end

      it "should create environment and space associations" do
        environment.users.should =~ [users[1], users[2], user]
        space.users.should =~ [users[1], users[2], user]
      end

      it "should not raise error when moderating again" do
        expect {
          post :moderate_members_requests, params
        }.to_not raise_error(AASM::InvalidTransition)
      end
    end
  end

  context "when unjoin from a course (POST unjoin)" do
    let!(:plan) { FactoryGirl.create(:plan, billable: course, user: course.owner) }

    before do
      course.join(user)
      login_as user
    end

    context "and it's the unique course which user has joined" do
      before do
        course.join user
        post :unjoin, nested_course_params
      end

      it "removes the user from itself" do
        course.users.should_not include(user)
      end

      it "removes the user from all spaces" do
        spaces.collect { |s| s.users.should_not include(user) }
      end

      it "removes the user from all enrolled subjects" do
        subjects.collect { |s| s.members.should_not include(user) }
      end

      it "should remove user from environment" do
        environment.users.should_not include(user)
      end
    end # context "and it's the unique course which user has joined"

    context "and it's not the unique course which user has joined" do
      let(:other_course) { FactoryGirl.create(:course, environment: environment) }
      before do
        other_course.join(user)
        post :unjoin, nested_course_params
      end

      it "should remove the user from itself" do
        course.users.should_not include(user)
      end

      it "should remove the user from all spaces" do
        expect(spaces.map(&:users).flatten).to_not include(user)
      end

      it "should remove the user from all enrolled subjects" do
        expect(subjects.map(&:members).flatten).to_not include(user)
      end

      it "should not remove user from others courses" do
        other_course.users.should include(user)
      end

      it "should not remove user from environment" do
        environment.users.should include(user)
      end
    end # context "and it's not the unique course which user has joined"
  end # context "when unjoin from a course (POST unjoin)"

  context "when responding a course invitation" do
    let!(:plan) do
      FactoryGirl.
        create(:plan, billable: course, user: course.owner, members_limit: 5)
    end
    let(:visitor) { FactoryGirl.create(:user) }

    before do
      course.create_quota
      login_as visitor
      course.invite visitor
    end

    context "and accepting" do
      before do
        post :accept, nested_course_params
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "accepts the invitation" do
        user.get_association_with(course).state.should == "approved"
        course.approved_users.should include(user)
      end
    end

    context "and denying" do
      it "assigns course" do
        post :deny, nested_course_params
        assigns[:course].should_not be_nil
      end

      it "denies the invitation" do
        post :deny, nested_course_params
        course.approved_users.should_not include(visitor)
      end

      it "detroys the UCA" do
        expect {
          post :deny, nested_course_params
        }.to change(UserCourseAssociation, :count).by(-1)
      end
    end
  end

  context "when destroying members" do
    let(:params) do
      nested_course_params.merge({"users" => users.collect { |u| u.id } })
    end

    before do
      login_as(user)
      post :destroy_members, params
    end

    it "destroys UCA" do
      users.each do |u|
        u.get_association_with(course).should be_nil
      end
    end

    it "destroys USA" do
      usas = spaces.collect do |s|
        users.collect { |u| u.get_association_with(s) }
      end.flatten

      usas.inject(true) { |acc,i| acc && (i.nil?) }.should be_true
    end

    it "destroys enrollments" do
      enrollments = spaces.collect do |s|
        s.subjects.collect do |subj|
          users.collect { |u| u.get_association_with(subj) }
        end
      end.flatten

      enrollments.inject(true) { |acc,i| acc && (i.nil?) }.should be_true
    end
  end

  context "when inviting users (POST invite_members)" do
    let(:params) do
      nested_course_params.
        merge(users: users.map(&:id).join(","), emails: emails.join(','))
    end
    let(:emails) { ["email@example.com", "email2@example.com", "email3@example.com"] }
    let(:users) { FactoryGirl.create_list(:user, 3) }
    before do
      login_as user
    end

    it "creates invitations" do
      post :invite_members, params

      users.each do |u|
        course.user_course_associations.reload
        u.reload
        course.waiting_user_approval?(u).should be_true
      end

      emails.each do |e|
        u = User.find_by_email(e)
        u.should be_nil
        course.invited?(e).should be_true
      end
    end
  end

  context "POST join" do
    context "when course is open" do
      let!(:subj) do
        FactoryGirl.
          create(:subject, space: space, owner: course.owner, finalized: true)
      end
      let(:visitor) { FactoryGirl.create(:user) }

      before do
        @plan = FactoryGirl.
          create(:active_package_plan, billable: course, user: course.owner)

        environment.create_quota
        environment.reload

        login_as(visitor)
      end

      it "should create all hieararchy" do
        post :join, nested_course_params

        course.users.should include(visitor)
        space.users.should include(visitor)
        subj.members.should include(visitor)
        course.environment.users.should include(visitor)
      end

    end
  end

  context "when the limit of members is full" do
    let(:visitor) { FactoryGirl.create(:user) }
    before do
      plan = FactoryGirl.
        create( :plan, billable: course, user: course.owner, members_limit: 5)
      course.create_quota
      users
    end

    context "and course isn't moderated" do
      it "should not authorize more 1 user" do
        login_as  visitor
        expect {
          post :join, nested_course_params
        }.to_not change(UserCourseAssociation, :count).by(1)
      end
    end

    context "and course is moderated" do
      before do
        course.update_attribute(:subscription_type, 2)
      end

      context "POST accept" do
        it "should not authorize more 1 user" do
          login_as user
          course.invite(visitor)

          login_as visitor
          expect {
            post :accept, nested_course_params
          }.to_not change(course.approved_users, :count).by(1)
        end
      end

      context "POST moderate_members" do
        it "should not authorize more 1 user" do
          login_as user
          course.join(visitor)

          @params = nested_course_params.merge( member: { visitor.id.to_s => "approve"})

          expect {
            post :moderate_members_requests, @params
          }.to_not change(course.approved_users, :count).by(1)
        end
      end
    end
  end

  context "when viewing sent invitations (GET admin_manage_invitations)" do
    before do
      login_as user
      course.invite FactoryGirl.create(:user)
      course.invite_by_email "email2121@example.com"

      get :admin_manage_invitations, nested_course_params
    end

    it "assigns user_invitations" do
      assigns[:user_invitations].should_not be_nil
    end

    it "assigns email_invitations" do
      assigns[:email_invitations].should_not be_nil
    end
  end

  context "when removing invitations (POST destroy_invitations)" do
    let(:email_invitations) do
      4.times.map { |i| course.invite_by_email "email#{i}@example.com" }
    end
    let(:user_invitations) do
      4.times.map { course.invite FactoryGirl.create(:user) }
    end

    before do
      login_as user
    end

    context "when email_invitations is empty" do
      before do
        nested_course_params[:email_invitations] = ""
        post :destroy_invitations, nested_course_params
      end

      it "does NOT destroy email invitations" do
        course.user_course_invitations.invited.should == email_invitations
      end
    end


    context "when email_invitations is NOT empty" do
      before do
        nested_course_params[:email_invitations] = email_invitations[0..1].map(&:id)
        post :destroy_invitations, nested_course_params
      end

      it "destroys specified email invitations" do
        course.user_course_invitations.invited.should == email_invitations[2..3]
      end
    end

    context "when user_invitations is empty" do
      before do
        nested_course_params[:user_invitations] = ""
        post :destroy_invitations, nested_course_params
      end

      it "does NOT destroy user invitations" do
        course.user_course_associations.invited.should == user_invitations
      end
    end

    context "when user_invitations is NOT empty" do
      before do
        nested_course_params[:user_invitations] = user_invitations[0..1].map(&:id)
        post :destroy_invitations, nested_course_params
      end

      it "destroys specified user invitations" do
        course.user_course_associations.invited.should == user_invitations[2..3]
      end
    end
  end

  # admin actions (management panel)
  context "on management panel" do
    let(:course_attrs) do
      { name: "course", workload: "", path: "course-path", tag_list: "", description: "", subscription_type: "1" }
    end
    let(:base_params) do
      nested_course_params.merge(course: course_attrs)
    end
    before  do
      login_as user
    end

    context "GET new" do
      before do
        get :new, base_params
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "renders admin/new" do
        response.should render_template "courses/admin/new"
      end
    end

    context "POST create" do
      context "when successful" do
        before do
          base_params.merge!(plan: :free)
        end

        it "redirects to Courses#show" do
          post :create, base_params
          response.should redirect_to(controller.environment_course_path(environment, Course.last))
        end
      end

      context "when failing" do
        before do
          course_attrs.merge!(name: "", path: "")
          base_params.merge!(plan: :free)
          post :create, base_params
        end

        it "re-renders course/admin/new" do
          response.should render_template "courses/admin/new"
        end
      end
    end

    context "GET edit" do
      before do
        get :edit, locale: "pt-BR", environment_id: environment.path, id: course.path
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "renders admin/edit" do
        response.should render_template "courses/admin/edit"
      end
    end

    context "POST update" do
      context "when successful" do
        before do
          base_params.merge!(plan: :free, id: course.path)
          post :update, base_params
        end

        it "redirects to Environments#show" do
          response.should \
            redirect_to(controller.environment_course_path(environment, course.reload))
        end
      end

      context "when failing" do
        before do
          course_attrs.merge!(path: "")
          post :update, base_params.merge!(plan: :free, id: course.path)
        end

        it "re-renders courses/admin/edit" do
          response.should render_template "courses/admin/edit"
        end
      end
    end

    context "GET reports" do
      before do
        get :teacher_participation_report, base_params.merge(id: course.path)
      end

      it "when successful" do
        response.should render_template "courses/admin/teacher_participation_report"
      end
    end
  end

  context "when course is unpublished" do
    context "GET show" do
      before do
        get :show, nested_course_params
      end

      it "should show the login/home page" do
        #path = controller.preview_environment_course_path(course.environment, course)
        response.should redirect_to(controller.home_path)
      end
    end
  end

  context "GET preview" do
    context "when have permission to see the course" do
      before do
        login_as user
        get :preview, nested_course_params
      end

      it "redirects to #show" do
        response.should redirect_to(controller.environment_course_path(environment, course))
      end
    end


    context "when is course's admin" do
      before do
        login_as user

        get :preview, nested_course_params
      end

      it "redirects to #show" do
        response.should redirect_to(controller.environment_course_path(environment, course))
      end
    end

    context "when does NOT have permission to see the course" do
      before do
        get :preview, nested_course_params
      end

      it "renders preview" do
        response.should  render_template("courses/preview")
      end

      it "should assign responsibles_associations" do
        assigns[:responsibles_associations].should_not be_nil
      end
    end
  end

  context "when visiting a course" do
    let(:visitor) { FactoryGirl.create(:user) }

    context "as a course's member" do
      before do
        login_as user
        course.join! visitor
      end

      it "updates uca's last_accessed_at" do
        expect {
          get :show, nested_course_params
        }.to change { user.user_course_associations.last.last_accessed_at }
      end

      it "should assign responsibles_associations" do
        get :show, nested_course_params
        assigns[:responsibles_associations].should_not be_nil
      end
    end
  end

  context "GET search_users_admin" do
    def search_memberships(params={})
      xhr :get, :search_users_admin, nested_course_params.merge(params)
    end

    before do
      login_as user
      search_memberships
    end

    it "assigns memberships" do
      assigns[:memberships].should_not be_nil
    end

    it "assigns spaces_count" do
      assigns[:spaces_count].should_not be_nil
    end

    it "renders admin/search_users_admin" do
      response.should render_template "courses/admin/search_users_admin"
    end

    context "with roles" do
      let(:role) { ['tutor'] }
      before do
        login_as user
        course.join(FactoryGirl.create(:user), Role[:tutor])

        search_memberships(role_filter: role)
      end

      it "assings the administrator memberships" do
        assigns[:memberships].map(&:role).map(&:to_s).should =~ role
      end
    end
  end

  context "GET admin_spaces" do
    context "with no spaces" do
      before { login_as user }
      it "should not raise error" do
        expect { get :admin_spaces, nested_course_params }.to_not raise_error
      end
    end
  end

  context "GET admin_invitations" do
    before { login_as user }

    it "should assigns the responsible associations" do
      get :admin_invitations, nested_course_params
      assigns[:responsibles_associations].should_not be_nil
    end
  end
end
