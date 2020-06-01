# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe EnvironmentsController do
  context "when creating a Environment" do
    before do
      User.maintain_sessions = false
      @user = FactoryGirl.create(:user)
      login_as @user

      @params = {:step => "1",
        :environment => {:name => "Faculdade mauricio de nassau",
          :initials => "FMN",
          :courses_attributes => [{:name => "Gestão de TI",
                                   :path => "gestao-de-ti"}],
        :path => "faculdade-mauricio-de-nassau"},
        :locale => "pt-BR"}
    end

    context "at step 1" do
      before do
        post :create, @params
      end

      it "assigns the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
        assigns[:step].should == 2
      end

      it "assigns the plan should be professor_plus" do
        assigns[:plan].name.should == "Professor Plus"
      end
    end

    context "at step 2" do

      context "when is valid" do
        before do
          @params[:step] = "2"
          @params[:plan] = "professor_standard"
          post :create, @params
        end

        it "assigns the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should be_valid
          assigns[:step].should == 3
        end

        it "assigns the plan" do
          assigns[:plan].name.should == "Professor Plus"
        end
      end

      context "when isn't valid" do
        before do
          @params[:step] = "2"
          @params[:plan] = "professor_standard"
          @params[:environment][:name] = ""
          post :create, @params
        end

        it "assigns the environment" do
         assigns[:environment].should_not be_nil
         assigns[:environment].should_not be_valid
         assigns[:step].should == 2
        end

        it "assigns the plan" do
          assigns[:plan].should_not be_nil
        end
      end
    end
    context "at step 3" do
      before do
        @params[:step] = "3"
        @params[:plan] = "free"
        @params[:color] = "f56b00"
        @params[:locale] = "pt-BR"
        @params[:format] = "js"

        post :create, @params
      end

      it "assigns and creates the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should_not be_new_record
      end

      it "assigns and creates the plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should be_valid
        assigns[:plan].should_not be_new_record
      end

      it "associates the plan to the course" do
        assigns[:environment].courses.first.plan.should == assigns[:plan]
      end

      it "associates the quota to the course" do
        course = assigns[:environment].courses.first
        course.quota.should_not be_nil
      end

      it "associates the plan with the user" do
        assigns[:plan].user.should == @user
      end

      it "redirects to course page" do
        response.should render_template "environments/redirect"
      end
    end
  end

  context "GET preview" do
    before do
      environment = FactoryGirl.create(:environment)
      courses = (1..5).collect { FactoryGirl.create(:course, :environment => environment) }

      get :preview, :id => environment.path, :locale => "pt-BR"
    end

    it "assigns courses" do
      assigns[:courses].should_not be_nil
    end
  end

  # admin actions (management panel)
  context "on management panel" do
    before  do
      @environment = FactoryGirl.create(:environment)
      @courses = (1..3).collect { FactoryGirl.create(:course, :environment => @environment) }
      @user = FactoryGirl.create(:user)
      @courses.each {|c| c.join @user, :environment_admin }
      login_as @user
    end

    context "GET edit" do
      before do
        get :edit, :locale => "pt-BR", :id => @environment.path
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "renders admin/edit" do
        response.should render_template "environments/admin/edit"
      end
    end

    context "POST update" do
      context "when successful" do
        before do
          @post_params = { :environment => { :name => "Pe" , :initials => "PE",
            :path => @environment.path, :tag_list => "", :description => "" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:id] = @environment.path
          post :update, @post_params
        end

        it "redirects to Environments#show" do
          response.should redirect_to(controller.environment_path(@environment))
        end
      end

      context "when failing" do
        before do
          @post_params = { :environment => { :name => "" , :initials => "PE",
            :path => "", :tag_list => "", :description => "" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:id] = @environment.path
          post :update, @post_params
        end

        it "re-renders environments/admin/edit" do
          response.should render_template "environments/admin/edit"
        end
      end
    end

    context "POST destroy" do
      before do
        @plan = FactoryGirl.create(:active_package_plan, :billable => @environment)
        @post_params = { :locale => "pt-BR" }
        @post_params[:id] = @environment.path
        post :destroy, @post_params
      end

      it "should store billable" do
        @plan.reload.billable_audit.should_not be_nil
      end
    end

    context "POST destroy_members" do
      before do
        @courses.each do |c|
          (1..2).each { FactoryGirl.create(:space, :course => c) }
          c.spaces.reload
        end

        @users = (1..3).collect { FactoryGirl.create(:user) }
        @courses[0].join @users[0]
        @courses[0].join @users[1]
        @courses[0].join @users[2]

        @courses[1].join @users[1]
        @courses[2].join @users[2]
      end

      it "calls remove_users" do
        Environment.any_instance.should_receive(:remove_users).
          with(@users[0..1])
        post_destroy_members(@environment, @users[0..1])
      end

      it 'sets flash properly' do
        post_destroy_members(@environment, @users[0..1])

        should set_the_flash.to("Os usuários foram removidos do ambiente #{@environment.name}")
      end
    end
  end

  context 'GET index' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      (1..3).collect { FactoryGirl.create(:environment) }
      @user_environments = (1..3).collect { FactoryGirl.create(:environment) }
      @user_environments.each { |e| user.environments << e }

      login_as user
    end

    context "my environments" do
      before do
        get :index, :user_id => user.to_param, :locale => 'pt-BR'
      end

      it 'assigns @user' do
        assigns[:user].should_not be_nil
        assigns[:user].should == user
      end

      it 'assigns all user environments to @environments' do
        assigns[:environments].should_not be_nil
        assigns[:environments].to_set.should == @user_environments.to_set
      end
    end

    context "environments" do
      before do
        get :index, :locale => 'pt-BR'
      end

      it { response.should render_template 'environments/index'}
    end
  end

  context "GET search_users_admin" do
    let(:environment) { FactoryGirl.create(:complete_environment) }
    let(:course) {  environment.courses.first }
    let(:role) { ['teacher'] }
    let(:params) do
      { id: environment.to_param, role_filter: role, search_user: "",
        locale: "pt-BR" }
    end

    before do
      login_as environment.owner
      course.join(FactoryGirl.create(:user), Role[:teacher])
      xhr :get, :search_users_admin, params
    end

    it "assings the teacher memberships" do
      assigns[:memberships].map(&:role).map(&:to_s).should =~ role
    end
  end

  def post_destroy_members(environment, users)
    post :destroy_members, :locale => 'pt-BR',
      :id => environment.to_param,
      :users => users.collect { |u| u.id }
  end
end
