# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Documents API" do
  let(:environment) { FactoryGirl.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { FactoryGirl.create(:subject, :owner => course.owner,
                          :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  context "when GET /lectures/:id" do
    context "with a document as attachment" do
      subject do
        FactoryGirl.create(:lecture, :lectureable => FactoryGirl.create(:document),
                :subject => subj, :owner => subj.owner)
      end

      before do
        get "/api/lectures/#{subject.id}", params
      end

      it_should_behave_like "a lecture"

      it "should have property mimetype" do
        parse(response.body).should have_key "mimetype"
      end

      it "should have the raw link" do
        href_to(raw, parse(response.body)).should_not be_blank
      end
    end

    context "with an image as attachment" do
      subject do
        FactoryGirl.create(:lecture, :lectureable => FactoryGirl.create(:document_with_image),
                :subject => subj, :owner => subj.owner)
      end

      before do
        get "/api/lectures/#{subject.id}", params
      end

      it_should_behave_like "a lecture"

      it "should have property mimetype" do
        parse(response.body).should have_key "mimetype"
      end

      it "should have the link raw" do
        href_to(raw, parse(response.body)).should_not be_blank
      end

    end
  end

  context "when POST /api/subjects/:id/lectures" do
    let(:url) { "/api/subjects/#{subj.id}/lectures"  }
    let(:mimetype) { "application/vnd.ms-powerpoint" }
    let(:lecture_params) do
      path = "#{RSpec.configuration.fixture_path}/api/document_example.pptx"
      { :lecture => \
        { :name => 'Lorem', :type => 'Document',
          :media => fixture_file_upload(path, mimetype) }
      }.merge(params)
    end

    it_should_behave_like "a lecture created"

    it "should have raw link" do
      post url, lecture_params
      lecture = parse(response.body)
      href_to("raw", lecture).should_not be_blank
    end

    context "with validation error" do
      let(:lecture_params) do
        { :lecture => { :name => 'Lorem', :type => 'Document', :media => nil } }.
          merge(params)
      end

      it "should return 422 HTTP code" do
        post "/api/subjects/#{subj.id}/lectures", lecture_params
        response.code.should == "422"
      end

      it "should return the validation error" do
        post "/api/subjects/#{subj.id}/lectures", lecture_params
        response.body.should =~ /lectureable\.attachment/
      end
    end
  end
end
