require 'spec_helper'

describe ChatsController do
  before do
    @current_user = FactoryGirl.create(:user)
    @friend1 = FactoryGirl.create(:user)
    @current_user.be_friends_with(@friend1)
    @friend1.be_friends_with(@current_user)

    login_as @current_user
  end

  context 'POST send_message' do
    before do
      @post_params = { :locale => "pt-BR",
        contact_id: @friend1.id,
        text: 'message'
      }
    end

    it "should be successful" do
      post 'send_message', @post_params
      response.should be_success
    end

    it "should create a new conversation" do
      Conversation.all.should be_empty
      post 'send_message', @post_params
      Conversation.all.should_not be_empty
      Conversation.between(@current_user, @friend1).should_not be_empty
    end

    it "should not create more than one conversation" do
      Conversation.all.should be_empty
      post 'send_message', @post_params
      post 'send_message', @post_params
      Conversation.count.should == 1
      Conversation.between(@current_user, @friend1).should_not be_empty
    end
  end
  context 'GET last_messages_with' do
    before do
      @post_params = { :locale => "pt-BR",
        contact_id: @friend1.id,
        text: 'message'
      }
      @get_params = { :locale => "pt-BR",
        contact_id: @friend1.id,
        messages_per_chat: 2
      }
      post 'send_message', @post_params
      post 'send_message', @post_params
      get 'last_messages_with', @get_params
    end

    it "should be successful" do
      response.should be_success
    end

    it "should have messages" do
      messages = [
        {
          user_id: @current_user.id,
          name: @current_user.display_name,
          thumbnail: @current_user.avatar.url(:thumb_24),
          text: 'message'
        },
        {
          user_id: @current_user.id,
          name: @current_user.display_name,
          thumbnail: @current_user.avatar.url(:thumb_24),
          text: 'message'
        }
      ]
      response.body.should == messages.to_json
    end
  end
end
