# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Vis Api" do
  # As requisições são feitas para api que faz a requisição para vis, essa
  # requisição de vis é que é testada pelo Webmock, o parametro
  # 'Authorization' de headers tem que ser comparado já encodado em Base64
  # pois a requisição já envia este parametro encodado e o Webmock
  # intercepta ele assim.

  before do
    environment = FactoryGirl.create(:complete_environment)
    course = environment.courses.first
    @space = course.spaces.first

    application, current_user, @token = generate_token(course.owner)
  end

  context "get /vis/spaces/:space_id/students_participation" do
    it "should send request to vis" do
      @params = {
        date_start: "2012-02-10",
        date_end: "2012-02-11",
        oauth_token: @token,
        format: 'json' }

      param = { date_start: @params[:date_start],
                date_end: @params[:date_end],
                space_id: "#{@space.id}" }

      test_request(:students_participation, param)
    end

    it "should return 404 when doesnt exists" do
      get "/api/vis/spaces/1212121/students_participation",
        oauth_token: @token,
        format: 'json'

      response.code.should == "404"
    end
  end

  context "get /vis/spaces/:space_id/lecture_participation" do
    it "should send request to vis" do
      @params = {
        lectures: ["2", "3"],
        date_start: "2012-02-10",
        date_end: "2012-02-11",
        oauth_token: @token,
        format: 'json' }

      param = { lectures: @params[:lectures],
                date_start: @params[:date_start],
                date_end: @params[:date_end] }

      test_request(:lecture_participation, param)
    end

    it "should return 404 when doesnt exists" do
      get "/api/vis/spaces/1212121/lecture_participation",
        oauth_token: @token,
        format: 'json'

      response.code.should == "404"
    end
  end

  context "get /vis/space/:space_id/subject_activities" do
    it "should return status 200" do
      @params = {
        subjects: ["2", "3"],
        oauth_token: @token,
        format: 'json' }

      param = { subjects: @params[:subjects] }

      test_request(:subject_activities, param)
    end

    it "should return 404 when doesn't exists" do
      get "/api/vis/spaces/121212/subject_activities",
        oauth_token: @token,
        format: 'json'

      response.code.should == "404"
    end
  end

  def test_request(url, param)
    WebMock.disable_net_connect!
    stub_request(:get, Redu::Application.config.vis[url]).
        with(query: param,
             headers: {'Authorization' => 'Og==',
                          'Content-Type' => 'application/json'}).
        to_return(status: 200, body: "", headers: {})

    get "/api/vis/spaces/#{@space.id}/#{url}", @params

    a_request(:get, Redu::Application.config.vis[url]).
        with(query: param,
             headers: {'Authorization'=> 'Og==',
                          'Content-Type'=>'application/json'}).
    should have_been_made
  end
end
