require 'spec_helper'

describe ChatMessage do

  it { should belong_to :conversation }
  it { should belong_to :user }
  it { should validate_presence_of :body }
  it { should validate_presence_of :conversation_id }
  it { should validate_presence_of :user_id }

  describe '.format_message' do
    it 'should a formated message' do
      @user = FactoryGirl.create(:user)
      @contact1 = FactoryGirl.create(:user)
      conversation = Conversation.create(sender: @user, recipient: @contact1)
      msg = 'Tudo bem?'
      message = conversation.chat_messages.create(user: @user, body: msg)
      message.format_message.should == {
        user_id: @user.id,
        name: @user.display_name,
        thumbnail: @user.avatar.url(:thumb_24),
        text: msg
      }
    end
  end
end
