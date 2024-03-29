class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :notified_by_id, type: String
  field :identifier, 		 type: String
  field :notice_type, 	 type: String
  field :read, 					 type: Boolean, default: false
  # current_user.notifications.last.notified_by
  # Returns the User object that made the notification
  belongs_to :notified_by, foreign_key: :notified_by_id, class_name: 'User', index: true
  belongs_to :user, index: true, counter_cache: true
  belongs_to :post, index: true, optional: true
  belongs_to :message, index: true, optional: true
  # validates :user_id, :notified_by_id, :post_id, :identifier, :notice_type, presence: true


	def build_notification_hash
    note = {
      id: self.id.to_s,
      created_at: self.created_at,
      notice_type: self.notice_type,
      user: {
        first_name: self.notified_by.first_name,
        last_name: self.notified_by.last_name,
        avatar: self.notified_by.avatar.url || "/assets/images/default-image.png",
        user_name: self.notified_by.user_name,
        id: self.notified_by.id.to_s
      }
    }
    note[:identifier] = self.identifier if self.identifier
    if self.post
      post = self.post
      note[:post] = post.build_post_hash
    end
    return note
  end

end