class ChatsController < ApplicationController
  def send_message
    recipient = User.find(params['contact_id'])

    authorize! :send_message, recipient

    text = params['text']

    conversation = Conversation.between(
      current_user.id,
      recipient.id
    ).first

    if conversation.blank?
      conversation = Conversation.create(
        sender: current_user,
        recipient: recipient
      )
    end

    message = conversation.chat_messages.build(user: current_user, body: text)

    if message.valid?
      message.save
      sender("/#{recipient.user_channel}", message.format_message)
    end

    head :ok, content_type: "text/html"
  end

  def last_messages_with
    recipient = User.find(params['contact_id'])

    authorize! :send_message, recipient

    conversation = Conversation.between(
      current_user.id,
      recipient.id
    ).first

    if conversation.blank?
      render json: []
    else
      messages = conversation.chat_messages.order('created_at')
      length = messages.count
      messages_per_chat = params['messages_per_chat'].to_i || length
      offset = [(length-messages_per_chat),0].max
      render json: messages[offset..(length-1)].map {|x| x.format_message }
    end
  end

  def online
    authorize! :online, :chats
    sender(
      "/online/confirm",
      {
        current_user.user_channel => current_user.id
      }
    )
    head :ok, content_type: "text/html"
  end

  protected

    def sender(channel, msg)
      message = {:channel => channel, :data => msg.merge(:authToken => ENV['FAYE_TOKEN'])}
      begin
        uri = URI.parse(Redu::Application.config.faye_url)
        Net::HTTP.post_form(uri, :message => message.to_json)
      rescue Exception => e
      end
    end
end
