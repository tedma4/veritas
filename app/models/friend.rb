class Friend
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  belongs_to :owner, :class_name => "User"
  belongs_to :friended, :class_name => "User"
  validates :owner_id, presence: true
  validates :friended_id, presence: true
  field :pending, :type => Boolean, :default => true
end