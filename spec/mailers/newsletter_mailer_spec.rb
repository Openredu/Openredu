# -*- encoding : utf-8 -*-
require 'spec_helper'

describe NewsletterMailer do
  subject { NewsletterMailer }
  context ".newsletter" do
    it "should deliver e-mail" do
      expect {
        subject.newsletter("foo@bar.com").deliver
      }.to change(subject.deliveries, :length).by(1)
    end

    it "should deliver to the correct e-mail" do
      subject.newsletter("foo@bar.com").deliver
      subject.deliveries.last.to.should include "foo@bar.com"
    end

    it "should choose the template" do
      template = "newsletter/inexistent_view"
      expect {
        subject.newsletter("foo@bar.com", :template => template).deliver
      }.to raise_error(ActionView::MissingTemplate)
    end
  end
end
