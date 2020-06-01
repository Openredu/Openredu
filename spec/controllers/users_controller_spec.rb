# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe UsersController do
  before do
    users = (1..4).collect { FactoryGirl.create(:user) }
    users[0].be_friends_with(users[1])
    users[0].be_friends_with(users[2])
    users[0].be_friends_with(users[3])
    users[1].be_friends_with(users[0])
    users[2].be_friends_with(users[0])
    @friends = [users[1], users[2]]
    @user = users[0]
  end

  context "POST create" do

    context "when creating an account" do
      before do
        @post_params = { :locale => 'pt-BR', :format => "js",
          :user => { "birthday(1i)" => "1986", :tos => "1",
            :email_confirmation=> "email@example.com", "birthday(2i)" => "4",
            :password_confirmation => "password", "birthday(3i)" => "6",
            :last_name => "Doe", :password => "password",
            :login => "userlogin", :email => "email@example.com",
            :first_name => "John" } }
      end

      context "when successfull" do
        before do
          post :create, @post_params
          @created_user = User.find_by_email(@post_params[:user][:email])
        end

        it "creates a user_setting" do
          @created_user.settings.should_not be_nil
          @created_user.settings.view_mural.should == Privacy[:friends]
        end

        it "creates a user with last_login_at" do
          @created_user.last_login_at.should_not be_nil
        end
      end

      context "with an invitation token" do
        context "and failing the validation" do
          before do
            course = FactoryGirl.create(:course)
            @invite = FactoryGirl.create(:user_course_invitation,
                              :email => "email@example.com", :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
            @post_params[:user][:password_confirmation] = "wrong-pass"
            post :create, @post_params
          end

          it "assigns environment" do
            assigns[:environment].should == @invite.course.environment
          end

          it "assigns course" do
            assigns[:course].should == @invite.course
          end

          it "assigns user_course_invitation" do
            assigns[:user_course_invitation].should == @invite
          end

        end

        context "and the same email that was invited" do
          before do
            course = FactoryGirl.create(:course)
            @invite = FactoryGirl.create(:user_course_invitation,
                              :email => @post_params[:user][:email],
                              :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
          end

          it "invites the new user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.to change(UserCourseAssociation, :count).by(1)
            UserCourseAssociation.last.user.email.
              should == @post_params[:user][:email]
          end
        end

        context "and with a different email from the invited one" do

          before do
            @another_email = "newemail@example.com"
            course = FactoryGirl.create(:course)
            @invite = FactoryGirl.create(:user_course_invitation,
                              :email => @another_email,
                              :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
            @post_params[:user][:email] = @another_email
            @post_params[:user][:email_confirmation] = @another_email
          end

          it "invites the new user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.to change(UserCourseAssociation, :count).by(1)
            UserCourseAssociation.last.user.email.should == @another_email
          end

        end
      end

      context "The request contains an invitation token" do
        before do
          @email = 'mail@example.com'
          @invitation = Invitation.invite(:user => @user,
                                          :hostable => @user,
                                          :email => 'mail@example.com')
          @post_params.store(:friendship_invitation_token, @invitation.token)
        end

        context "User as succcessfully created" do
          before do
            post :create, @post_params
            @created_user = User.find_by_email(@post_params[:user][:email])
          end

          it "invite should be accepted (Invitation should be destroyed)" do
            Invitation.all.should be_empty
          end

          it "friendship request should be created" do
            @created_user.friendships.should_not be_empty
          end

          it "response should be success" do
            response.should be_success
          end
        end

        context "User params validation fail" do
          before do
            @post_params[:user][:password_confirmation] = "wrong-pass"
            post :create, @post_params
            @created_user = User.find_by_email(@post_params[:user][:email])
          end

          it "assigns user" do
            assigns(:invitation_user).should == @invitation.user
          end

          it 'assigns contacts' do
            assigns(:contacts)[:total].should == @invitation.user.friends.count
          end

          it 'assigns courses' do
            uca = UserCourseAssociation.where(:user_id => @invitation.user).approved
            @courses = { :total => @invitation.user.courses.count,
                         :environment_admin => uca.with_roles([:environment_admin]).count,
                         :tutor => uca.with_roles([:tutor]).count,
                         :teacher => uca.with_roles([:teacher]).count }

            assigns(:courses)[:total].should == @courses[:total]
            assigns(:courses)[:environment_admin].should == @courses[:environment_admin]
            assigns(:courses)[:tutor].should == @courses[:tutor]
            assigns(:courses)[:teacher].should == @courses[:teacher]
          end
        end
      end
    end
  end

  context "POST update" do
    before do
      @user = FactoryGirl.create(:user)
      login_as @user

      @post_params = { :locale => "pt-BR", :id => @user.login, :user => {
        "birthday(1i)"=>"1991", "birthday(2i)"=>"6", "birthday(3i)"=>"8",
        :mobile => "", :last_name => "Last", :localization => "",
        :description => "", :first_name => "First" } }
    end

    context "when successful" do
      before do
        post :update, @post_params
      end

      it "updates the user" do
        @user.reload
        @user.first_name.should == @post_params[:user][:first_name]
        @user.last_name.should == @post_params[:user][:last_name]
      end

      it "redirects to edit_user_path" do
        response.should redirect_to(controller.edit_user_path(@user))
      end
    end

    context "when failing" do
      before do
        @real_name = @user.first_name
        @post_params[:user][:first_name] = ""
        post :update, @post_params
      end

      it "does NOT update the user" do
        assigns[:user].errors.should_not be_empty
        @user.reload.first_name.should == @real_name
      end

      it "re-reders users/edit" do
        response.should render_template("users/edit")
      end

      context "to render form errors" do
        it "assigns @experience" do
          assigns[:experience].should_not be_nil
        end

        it "assigns @high_school" do
          assigns[:high_school].should_not be_nil
        end

        it "assigns @higher_education" do
          assigns[:higher_education].should_not be_nil
        end

        it "assigns @complementary_course" do
          assigns[:complementary_course].should_not be_nil
        end

        it "assigns @event_education" do
          assigns[:event_education].should_not be_nil
        end
      end
    end
  end

  context "POST update_account" do
    before do
      @user = FactoryGirl.create(:user)
      login_as @user

      @post_params =
        { :locale => "pt-BR",
          :current_password => @user.password,
          :id => @user.login,
          :user => {
            :email => "new_email@example.com",
            :email_confirmation => "new_email@example.com",
            :auto_status => "1",
            :notify_messages => "1",
            :notify_community_news => "1",
            :notify_followships => "1",
            :password => "new-pass",
            :password_confirmation => "new-pass",
            :settings_attributes => {
              :id => @user.settings.id,
              :view_mural => :public
            }
          }
        }
    end

    context "when successful" do
      before do
        post :update_account, @post_params
        @user.reload
      end

      it "updates the user account informations" do
        @user.email.should == @post_params[:user][:email]
      end

      it "should updates user password" do
        @user.password == @post_params[:user][:password]
      end

      it "redirects to account_user_path" do
        response.should redirect_to(controller.account_user_path(@user))
      end
    end

    context "when failing" do
      context "wrong password" do
        before do
          @post_params[:current_password] = "wrong-pass"
          post :update_account, @post_params
          @user.reload
        end

        it "does NOT update the user account informations" do
          @user.email.should_not == @post_params[:user][:email]
        end

        it "should add some errors on user" do
          assigns[:user].errors.should_not be_empty
        end

        it "re-renders users/account" do
          response.should render_template("users/account")
        end
      end
    end
  end

  context "POST destroy" do
    before do
      @user = FactoryGirl.create(:user)
      login_as @user

      @post_params = { :locale => "pt-BR", :id => @user.login }
    end

    it "destroys the user" do
      expect {
        post :destroy, @post_params
      }.to change(User, :count).by(-1)
    end

    it "redirects to site_index" do
        post :destroy, @post_params
        response.should redirect_to(controller.home_path)
    end
  end

  context "GET home" do
    before do
      @user = FactoryGirl.create(:user)
      login_as @user

      @params = { :locale => "pt-BR", :id => @user.login }
    end

    [:friends_requisitions, :course_invitations, :statuses].each do |var|
      it "assigns @#{var}" do
        get :home, @params

        assigns[var].should_not be_nil
      end
    end
  end

  context "GET curriculum" do
    before do
      @user = FactoryGirl.create(:user)
      login_as @user
      get :curriculum, { :locale => "pt-BR", :id => @user.login }
    end

    [:experience, :high_school, :higher_education,
      :complementary_course, :event_education].each do |v|
      it "assigns #{v}" do
        assigns[v].should_not be_nil
      end
    end
  end

  context "GET index" do
    context "an strange" do
      context "when viewing Environment users" do
        before do
          environment = FactoryGirl.create(:environment)
          get :index, { :locale => "pt-BR", :environment_id => environment.path }
        end

        it "has access, so assigns users" do
          assigns[:users].should_not be_nil
        end

        it "renders environments/users/index" do
          response.should render_template("environments/users/index")
        end
      end

      context "when viewing Course users" do
        before do
          environment = FactoryGirl.create(:environment)
          course = FactoryGirl.create(:course, :environment => environment)
          get :index, { :locale => "pt-BR", :environment_id => environment.path,
            :course_id => course.path }
        end

        it "has access" do
          assigns[:users].should_not be_nil
        end

        it "renders courses/users/index" do
          response.should render_template("courses/users/index")
        end
      end

      context "when viewing Space users" do
        before do
          @environment = FactoryGirl.create(:environment)
          @course = FactoryGirl.create(:course, :environment => @environment)
          space = FactoryGirl.create(:space, :course => @course)
          get :index, { :locale => "pt-BR", :space_id => space.id }
        end

        it "does NOT have access, so does not assigns users" do
          assigns[:users].should be_nil
        end

        it "redirect to Courses#Preview" do
          response.should redirect_to(controller.preview_environment_course_path(@environment,
                                                                      @course))
        end
      end
    end

    context "a member" do
      context "when viewing Space users" do
        before do
          @environment = FactoryGirl.create(:environment)
          @course = FactoryGirl.create(:course, :environment => @environment)
          space = FactoryGirl.create(:space, :course => @course)
          user = FactoryGirl.create(:user)
          @course.join user
          login_as user
          get :index, { :locale => "pt-BR", :space_id => space.id }
        end

        it "has access" do
          assigns[:users].should_not be_nil
        end

        it "renders spaces/users/index" do
          response.should render_template("spaces/users/index")
        end
      end
    end
  end

  context "GET my_wall" do
    before do
      @contact = FactoryGirl.create(:user)
      @user = FactoryGirl.create(:user)
      login_as @user
    end

    [:statuses, :status].each do |var|
      it "assigns @#{var}" do
        @params = { :locale => "pt-BR", :id => @user.login }
        get :my_wall, @params
        assigns[var].should_not be_nil
      end
    end

    it "when strange/contact access my_wall redirects to home" do
      @params = { :locale => "pt-BR", :id => @contact.login }
      get :my_wall, @params
      response.should redirect_to(controller.home_path)
    end

    context "when exists compound logs" do
      before do
        @params = {:locale => "pt-BR", :id => @user.login }
        @statuses = @user.statuses.where(:compound => false)

        # Criando friendship (para gerar um status compondable)
        ActiveRecord::Observer.with_observers(:log_observer,
                                              :friendship_observer) do
                                                friend = FactoryGirl.create(:user)
                                                friend.be_friends_with(@user)
                                                @user.be_friends_with(friend)
                                              end

        get :my_wall, @params
      end

      it "assigns correctly number of statuses." do
        assigns[:statuses].to_set.should == @statuses.to_set
      end
    end
  end

  context "GET show" do
    before do
      @user = FactoryGirl.create(:user)
      @courses = 4.times.collect { FactoryGirl.create(:course) }
      @moderated_courses = 4.times.collect { FactoryGirl.create(:course,
                                                     :subscription_type => 2) }
      @approved_courses = @courses[0..2].each { |c| c.join(@user) }
      @moderated_courses[0..2].each { |c| c.join(@user) }

      login_as @user

      get :show, :locale => "pt-BR", :id => @user.login
    end

    it "assigns subscribed_courses_count" do
      assigns[:subscribed_courses_count].should_not be_nil
      assigns[:subscribed_courses_count].should == @approved_courses.size
    end
  end

  context "GET show_mural" do
    before do
      @user = FactoryGirl.create(:user)
      @courses = 4.times.collect { FactoryGirl.create(:course) }
      @moderated_courses = 4.times.collect { FactoryGirl.create(:course,
                                                     :subscription_type => 2) }

      @approved_courses = @courses[0..2].each { |c| c.join(@user) }
      @moderated_courses[0..2].each { |c| c.join(@user) }

      @params = {:locale => "pt-BR", :id => @user.login }

      login_as @user
    end

    it "assigns subscribed_courses_count" do
      get :show_mural, @params
      assigns[:subscribed_courses_count].should_not be_nil
      assigns[:subscribed_courses_count].should == @approved_courses.size
    end

    context "when exists compound logs" do
      before do
        @statuses = @user.statuses.where(:compound => false)

        # Criando friendship (para gerar um status compondable)
        ActiveRecord::Observer.with_observers(:log_observer,
                                              :friendship_observer) do
                                                friend = FactoryGirl.create(:user)
                                                friend.be_friends_with(@user)
                                                @user.be_friends_with(friend)
                                              end

        get :show_mural, @params
      end

      it "assigns correctly number of statuses." do
        assigns[:statuses].to_set.should == @statuses.to_set
      end
    end
  end

  context "when recovering login or password" do
    context "GET recover_username_password" do
      before do
       get :recover_username_password, :locale => "pt-BR"
      end

      it "assigns recover_password" do
        assigns[:recover_password].should_not be_nil
        assigns[:recover_password].should be_kind_of(RecoveryEmail)
      end
    end

    context "POST recover_password" do
      context "when submitting an registered email" do
        before do
          UserNotifier.delivery_method = :test
          UserNotifier.perform_deliveries = true
          UserNotifier.deliveries = []

          @user = FactoryGirl.create(:user)
          post :recover_password, :locale => "pt-BR", :format => "js", :recovery_email => { :email => @user.email }

        end

        it "assigns user" do
          assigns[:user].should_not be_nil
          assigns[:user].should be_kind_of(User)
        end

        it "assigns recover_password" do
          assigns[:recover_password].should_not be_nil
          assigns[:recover_password].should be_kind_of(RecoveryEmail)
        end

        it "sends an email" do
          UserNotifier.deliveries.size.should == 1
        end
      end

      context "when submitting an UNregistered email" do
        before do
          @user = FactoryGirl.create(:user)
          post :recover_password, :locale => "pt-BR", :format => "js", :recovery_email => { :email => "iamnot@redu.com.br" }
        end

        it "assigns user" do
          assigns[:user].should be_nil
        end

        it "assigns recover_password" do
          assigns[:recover_password].should_not be_nil
          assigns[:recover_password].should be_kind_of(RecoveryEmail)
        end

        it "adds an error to recover_password" do
          assigns[:recover_password].errors.should_not be_empty
        end
      end
    end
  end

  context "context GET" do
    it "redirects to application_path" do
      get :new, :locale => 'pt-BR'
      response.should redirect_to(controller.application_path(:anchor => "modal-sign-up"))
    end
  end

  describe "GET resend_activation" do
    let(:user) { FactoryGirl.create(:user) }

    context "with email" do
      it "assigns @user" do
        get :resend_activation, :locale => "pt-BR", :email => user.email
        assigns[:user].should == user
      end

      it "delivers a signup notification" do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        expect {
          get :resend_activation, :locale => "pt-BR", :email => user.email
        }.to change(UserNotifier.deliveries, :count).by(1)

        UserNotifier.deliveries.last.subject.should =~ /Ative sua conta/
      end
    end

    context "with id" do
      it "assigns @user" do
        get :resend_activation, :locale => "pt-BR", :id => user.id
        assigns[:user].should == user
      end

      it "delivers a signup notification" do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        expect {
          get :resend_activation, :locale => "pt-BR", :id => user.id
        }.to change(UserNotifier.deliveries, :count).by(1)

        UserNotifier.deliveries.last.subject.should =~ /Ative sua conta/
      end
    end
  end
end
