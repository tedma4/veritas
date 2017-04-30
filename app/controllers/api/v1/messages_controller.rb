class Api::V1::MessagesController < Api::V1::BaseController
  require 'string_image_uploader'
	
	def new
		@message = Message.new
	end

	def create
		@message = Message.create(message_params)
		@message.save
	end

	def index
		@chat = Chat.find(params[:chat_id])
		@messages = @chat.messages
		respond_with @messages.map(&:build_message_hash	)
	end

	private

	def message_params
		the_params = params.require(:message).permit(:user_id, :chat_id, :message_type, :text, :content, :location, :timestamp)
		the_params[:content] = StringImageUploader.new(the_params[:content], 'message') if the_params[:content]
		the_params
	end

end