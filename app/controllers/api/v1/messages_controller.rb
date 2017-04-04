class Api::V1::MessagesController < Api::V1::BaseController
	
	def new
		@message = Message.new
	end

	def create
		params[:user_id] = @current_user.id
		@chat = Chat.find(params[:chat_id])
		@message = Message.create(message_params)
		@chat.messages << @message
		@chat.save
		# ChatChannel.send_message(@message)
	end

	private

	def message_params
		params.require(:message).permit(:post, :notification, :message_type, :text)
	end

end