# -*- encoding : utf-8 -*-
module StatusService
  module ActivityAdditions
    module ActsAsActivity
      extend ActiveSupport::Concern
      included do
        validates_presence_of :text
        validates_length_of :text, :maximum => 1600
      end

      def respond(attrs, user, &block)
        block_given = block_given?
        answer = Facade.instance.answer_status(self, attrs) do |a|
          a.user = user
          block.call(a) if block_given
        end

        self.update_attribute(:updated_at, Time.zone.now) if answer.valid?

        answer
      end
    end
  end
end
