# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe "User" do
  before do
    @user = FactoryGirl.create(:user, mobile: "+55 (81) 9194-5317",
                    localization: "Recife", birth_localization: "Recife",
                    description: "Descrição usuário",
                    favorite_quotation: "rede social educacional")
    @application, @current_user, @token = generate_token(@user)
  end

  context "when GET /user/:id" do
    let(:social_networks) do
      2.times.collect { FactoryGirl.create(:social_network, user: @current_user) }
    end

    let(:tags) { "educação, informática" }

    it "should return status 200 (ok)" do
      get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'
      response.code.should == "200"
    end

    it "should have login, id, links, email, first_name, last_name," + \
       " birthday, friends_count, created_at updated_at, mobile, localization," + \
       " birth_localization, social_networks interested_areas thumbnails" do
      get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'

      %w(login id links email first_name last_name description favorite_quotation birthday friends_count created_at updated_at mobile localization birth_localization social_networks interested_areas thumbnails).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should hold user social networks" do
      @current_user.social_networks << social_networks
      get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'

      parse(response.body)['social_networks'].count.should == 2
    end

    it "should hold the correct social network" do
      @current_user.social_networks << social_networks
      get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'

      sn = parse(response.body)['social_networks'].first
      sn['profile'].should == social_networks.first.url
    end

    context "interested areas" do
      before do
        @user.tag_list = tags
        @user.save
        get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'
      end

      it "should hold user interested areas" do
        parse(response.body)['interested_areas'].count.should == 2
      end

      it "should hold correct intereseted areas" do
        sn = parse(response.body)['interested_areas'].first
        sn['name'].should == @user.tags.first.name
      end
    end

    %w(self enrollments statuses timeline contacts connections).each do |rel|
      it "should link to #{rel}" do
        get "/api/users/#{@user.id}", oauth_token: @token, format: 'json'
        link = href_to(rel, parse(response.body))

        get link, oauth_token: @token, format: 'json'
        response.code.should == '200'
      end
    end
  end

  context "when GET /me" do
    it "should show current_user info" do
      get "/api/me", oauth_token: @token, format: 'json'

      parse(response.body)['id'].should == @current_user.id
    end
  end

  context "when listing users" do
    before do
      @environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      @course = @environment.courses.first
      @space = @course.spaces.first

      @members = 3.times.collect do
        user = FactoryGirl.create(:user)
        @course.join(user)
        user
      end
      @members << @course.owner
    end

    context "on course" do
      it_should_behave_like "user listing" do # spec/support/api/user_listing...
        let(:subject) { @course }
        let(:token) { @token }
        let(:members) { @members }
        let(:entity_name) { "#{subject.class.to_s.tableize}" }
      end
    end

    context "on space" do
      it_should_behave_like "user listing" do # spec/support/api/user_listing...
        let(:subject) { @space }
        let(:token) { @token }
        let(:members) { @members }
        let(:entity_name) { "#{subject.class.to_s.tableize}" }
      end
    end

    context "on environment" do
      it_should_behave_like "user listing" do # spec/support/api/user_listing...
        let(:subject) { @environment }
        let(:token) { @token }
        let(:members) { @members }
        let(:entity_name) { "#{subject.class.to_s.tableize}" }
      end
    end
  end

  context "when listing contacts" do
    let(:friend) { FactoryGirl.create(:user) }
    before do
      @current_user.be_friends_with(friend)
      friend.be_friends_with(@current_user)
    end

    it "should return the correct number of contacts" do
      get "/api/users/#{@current_user.id}/contacts", oauth_token: @token,
        format: 'json'

      parse(response.body).length.should == 1
    end
  end

  context "when GET /space/:space_id/users to a non-existent space" do
    it "should return code 404 (not existent)" do
      get "/api/spaces/2198219/users", oauth_token: @token,
        format: 'json'

      response.code.should == '404'
    end
  end


  context "when GET /space/:space_id/user to a non-existent space" do
    it "should return code 404 (not existent)" do
      get "/api/courses/2198219/users", oauth_token: @token,
        format: 'json'

      response.code.should == '404'
    end
  end
end
