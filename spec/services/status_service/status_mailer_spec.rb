require 'spec_helper'

module StatusService
  module Mailers
    describe StatusMailer do
      subject { StatusMailer }
      let(:user) { FactoryGirl.build_stubbed(:user) }
      let(:answer) { FactoryGirl.build_stubbed(:answer) }
      let(:notification) do
        AnswerService::AnswerNotification.new(user: user, answer: answer)
      end

      context ".new_answer" do
        xit "should deliver answer notification" do
          expect {
            subject.new_answer(notification).deliver
          }.to change(subject.deliveries, :length).by(1)
        end
      end
    end
  end
end
