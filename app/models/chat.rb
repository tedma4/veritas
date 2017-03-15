class Chat
	include Mongoid::Document
  include Mongoid::Timestamps
  # associations
	belongs_to :area, index: true, optional: true
	has_and_belongs_to_many :users#, index: true
	belongs_to :creator, class_name: "User", inverse_of: :user_chats, index: true, optional: true
	# chat fields
	field :title, type: String
	field :chat_type, type: String, default: "private" # "private", "geo", "user"
	# Chat statues are for finding out with chats to archive/destroy
	field :status, type: String, default: "active" # "active", "stale", "pending", nil, "delete this bitch"
	# Favorites are a future thing
	# Users can have many favorite Chats
	# Many Users can favorite the same chat
	# field :favorite, type: Array, default: Array.new

	# messages 
	embeds_many :messages
	def build_chat_hash
		chat = {
			id: self.id.to_s,
			users: self.user_ids.map(&:to_s),
			chat_type: self.chat_type,
			status: self.status
		}
		chat[:title] = self.title if self.title
		chat[:area] = self.area_id.to_s if self.area_id
		chat[:creator] = self.creator.id.to_s if self.creator
		unless self.messages.blank?
			chat[:messages] = self.messages.map(&:build_message_hash)
		else
			chat[:messages] = self.messages
		end
		chat
	end
end