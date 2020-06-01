class ChatMessage < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  validates_presence_of :body, :conversation_id, :user_id

  def format_message
    {
      user_id: user.id,
      name: user.display_name,
      thumbnail: user.avatar.url(:thumb_24),
      text: body
    }
  end
end
