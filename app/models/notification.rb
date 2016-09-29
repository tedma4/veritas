class Notification
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :user_id, 			 type: String
  field :notified_by_id, type: String
  field :post_id, 		   type: String
  # field :identifier, 		 type: String
  field :notice_type, 	 type: String
  field :read, 					 type: Boolean, default: false

  # current_user.notifications.last.notified_by
  # Returns the User object that made the notification
  belongs_to :notified_by, foreign_key: :notified_by_id, class_name: :User, index: true
  belongs_to :user, index: true
  belongs_to :post, index: true
  # validates :user_id, :notified_by_id, :post_id, :identifier, :notice_type, presence: true


	def build_notification_hash
    {
      id: self.id,
      created_at: self.created_at,
      notice_type: self.notice_type,
      user: {
        first_name: self.notified_by.first_name,
        last_name: self.notified_by.last_name,
        avatar: self.notified_by.avatar.url,
        user_name: self.notified_by.user_name
      }
    }
  end

end