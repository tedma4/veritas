class Like 
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :post, index: true
  belongs_to :user, index: true
  validates :user_id, uniqueness: { scope: :post_id }

end