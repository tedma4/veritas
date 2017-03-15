class Message
  include Mongoid::Document
  include Mongoid::Timestamps
	embedded_in :chat
	belongs_to :user, index: true, optional: true
	has_one :post
	has_one :notification
	field :message_type, type: String, default: "text" # "notification", "post", 
	field :text, type: String
	# Future fields, idk what they are yet
	# field :url, type: String
	# field :other, type: String

	def build_message_hash
		message = {
			id: self.id.to_s,
			message_type: self.message_type
		}
			message[:user_id] = self.user_id.to_s if self.user_id
			message[:post_id] = self.post.id.to_s if self.post
			message[:notification_id] = self.notification.id.to_s if self.notification
			message[:text] = self.text if self.text
			message
	end
end