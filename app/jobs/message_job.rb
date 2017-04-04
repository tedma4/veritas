class MessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast "chat_#{message.chat.id.to_s}", message: message
  end
end
