# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Seminar do
  subject { FactoryGirl.create(:seminar) }

  it "should have one lecture" do
    pending "Need seminar factory" do
      should have_one :lecture
    end
  end

  it "validates youtube URL"
  it "truncates youtube URL"

  context "#external_resource_url" do
    subject { FactoryGirl.create(:seminar_youtube) }

    it "should return fully fladged URL" do
      subject.external_resource_url.should == \
        "https://www.youtube.com/embed/#{subject.external_resource}"
    end

    it "should accept Youtube URL in any order" do
      url = "https://www.youtube.com/watch?feature=player_embedded&v=3ZNdzDglRms"

      FactoryGirl.create(:seminar_youtube,
              :external_resource_url => url).external_resource.
        should == "3ZNdzDglRms"
    end

    context "upload" do
      subject { FactoryGirl.create(:seminar_upload) }
      it "should return nil when there isn't a external_resource" do
        subject.external_resource_url.should be_nil
      end
    end
  end

  context "#external_resource" do
    context "youtube" do
      subject { FactoryGirl.create(:seminar_youtube) }
      it "should be 'youtube'" do
        subject.external_resource_type.should == 'youtube'
      end
    end
  end
end
