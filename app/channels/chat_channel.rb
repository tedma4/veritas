class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "chat_#{params[:chat_id]}"
    # logger.add_tags 'ActionCable', data
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
  	ActionCable.server.broadcast "chat_", message: data
  	# current_user.messages.create!(body: data['message'], chat_room_id: data['chat_room_id'])
  	# process data sent from the request
  	# current_user.messages.create!(body: data['message'], chat_id: data['chat_id'])
  end
end
