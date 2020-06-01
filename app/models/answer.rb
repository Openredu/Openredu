# -*- encoding : utf-8 -*-
class Answer < Status
  belongs_to :in_response_to, :polymorphic => true

  validates_presence_of :text, :maximum => 1600
end
