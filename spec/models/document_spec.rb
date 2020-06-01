# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Document do
  subject { FactoryGirl.build(:document) }

  it { should have_attached_file(:attachment) }

  describe "validates" do
    context "content_type" do
      it "should be invalid for not acceptable types" do
        subject.attachment_content_type = "application/fay"

        subject.should_not be_valid
        subject.errors[:attachment_content_type].should_not be_empty
      end

      it "should be valid for document types" do
        subject.attachment_content_type = "application/pdf"
        subject.should be_valid
      end

      it "should be valid for image types" do
        subject.attachment_content_type = "image/jpeg"
        subject.should be_valid
      end
    end
  end

end
