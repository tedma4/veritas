class Like 
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :post, index: true, counter_cache: true
  belongs_to :user, index: true, counter_cache: true
  validates :user_id, uniqueness: { scope: :post_id }

end