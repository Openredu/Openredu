class ChangeChatMessages < ActiveRecord::Migration
  def change
    change_table :chat_messages do |t|
      t.text :body
      t.remove :message
      t.references :conversation
    end

    add_index :chat_messages, :conversation_id
  end
end
