class Conversation < ActiveRecord::Base
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'

  has_many :chat_messages, dependent: :destroy

  validates_uniqueness_of :sender_id, :scope => :recipient_id

  def self.involving(user)
    where("conversations.sender_id =? OR conversations.recipient_id =?",user.id,user.id)
  end

  def self.between(sender_id,recipient_id)
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", sender_id,recipient_id, recipient_id, sender_id)
  end
end
