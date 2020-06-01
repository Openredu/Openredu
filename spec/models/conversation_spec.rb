require 'spec_helper'

describe Conversation do

  it { should belong_to :sender }
  it { should belong_to :recipient }
  it { should have_many(:chat_messages).dependent(:destroy) }
  it { should validate_uniqueness_of(:sender_id).scoped_to(:recipient_id)}

  before do
    @user = FactoryGirl.create(:user)
    @contact1 = FactoryGirl.create(:user)
    @contact2 = FactoryGirl.create(:user)
  end

  describe '.involving' do

    it 'should return []' do
      Conversation.involving(@user).should be_empty
      Conversation.involving(@contact1).should be_empty
    end

     it 'should return a conversation' do
      conversartion = Conversation.create(sender: @user, recipient: @contact1)
      Conversation.involving(@user).first.should eq conversartion
    end

    it 'should return two conversations' do
      conversartion1 = Conversation.create(sender: @user, recipient: @contact)
      conversartion2 = Conversation.create(sender: @user, recipient: @contact2)
      Conversation.involving(@user).should == [
        conversartion1,
        conversartion2
      ]
    end
  end

  describe '.between' do

    it 'should return []' do
      Conversation.between(@user, @contact1).should be_empty
    end

     it 'should return a conversation' do
      conversartion = Conversation.create(sender: @user, recipient: @contact1)
      Conversation.between(@user, @contact1).first.should eq conversartion
    end

    it 'should return just a conversation' do
      conversartion1 = Conversation.create(sender: @user, recipient: @contact1)
      conversartion2 = Conversation.create(sender: @user, recipient: @contact2)
      Conversation.between(@user, @contact1).first.should == conversartion1
    end
  end
end
