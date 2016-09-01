class Notification
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :user_id, 			 type: String, index: true
  field :notified_by_id, type: String, index: true
  field :post_id, 		   type: String, index: true
  field :identifier, 		 type: String
  field :notice_type, 	 type: String
  field :read, 					 type: Boolean, default: false

  belongs_to :notified_by_id, class_name: 'User'
  belongs_to :user
  belongs_to :post
  # validates :user_id, :notified_by_id, :post_id, :identifier, :notice_type, presence: true

end