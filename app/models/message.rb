class Message
  include Mongoid::Document
  # include Mongoid::Timestamps
  include Mongoid::Geospatial
	mount_uploader :content, AttachmentUploader
	# embedded_in :chat
	belongs_to :user, index: true, optional: true
	belongs_to :chat, index: true, optional: true
	# has_one :post
	# has_one :notification
	field :message_type, type: String, default: "text" # "notification", "post", 
	field :text, type: String
	field :location, type: Point, sphere: true
	field :timestamp, type: DateTime

  # validates_presence_of :content
  delegate :url, :size, :path, to: :content
  field :content, type: String#, null: false

	# after_create { MessageJob.perform_later(self) }
	# Future fields, idk what they are yet
	# field :url, type: String
	# field :other, type: String

	def build_message_hash
		user = self.user
		message = {
			id: self.id.to_s,
			message_type: self.message_type
		}
			message[:chat_id] = self.chat_id.to_s if self.chat_id
			message[:user] = {
				id: self.user_id.to_s, 
				user_name: user.user_name, 
				avatar: user.avatar.url,
				first_name: user.first_name,
				last_name: user.last_name
				} if user
			message[:text] = self.text || ''
			message[:content] = self.content.url || ''
			# self.content if self.content
			# message[:notification_id] = self.notification.id.to_s if self.notification
			message
	end
end
