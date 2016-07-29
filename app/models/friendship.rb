class Friendship
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  belongs_to :owner, :class_name => "User"
  belongs_to :friend, :class_name => "User", type: Array
  validates :owner_id, presence: true
  validates :friend_id, presence: true
  field :pending, :type => Boolean, :default => true
end