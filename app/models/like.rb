class Like 
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :post
  belongs_to :user
  validates :user_id, uniqueness: { scope: :post_id }

end