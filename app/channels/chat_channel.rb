class ChatChannel < ApplicationCable::Channel
  def subscribed
  	# binding.pry
    # stream_from "some_channel"
    stream_from "chat_chat_chat_chat"
    logger.add_tags 'ActionCable', "wubba lubba dub dub"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
  	ActionCable.server.broadcast("chat_#{params[:chat_id]}", data)
  	# process data sent from the request
  	# current_user.messages.create!(body: data['message'], chat_id: data['chat_id'])
  end
end
