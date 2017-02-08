class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic
	mount_uploader :attachment, AttachmentUploader
	belongs_to :user, index: true, counter_cache: true
  has_many :notifications, dependent: :destroy  
  has_many :likes, dependent: :destroy

  # Validations
  # validates_presence_of :attachment
  # validates_integrity_of :post

  # Callbacks
  # before_save :update_post_attributes

  # Delegate
  delegate :url, :size, :path, to: :attachment

  field :attached_item_id, type: Integer
  field :attached_item_type, type: String 
  field :attachment, type: String#, null: false
  field :original_filename, type: String

  # Virtual attributes
  alias_attribute :filename, :original_filename
  field :content_type, type: String
  field :location, type: Point, sphere: true
  field :post_type, type: String, default: "public"
  field :selected_users, type: Array
  field :caption, type: String
  # validates :user_id, presence: true

  def build_post_hash(*likes)
    post_hash = {
      id: self.id.to_s,
      created_at: self.created_at,
      image: self.attachment.url || "res://avatardefault",
      location: {latitude: self.location.y, longitude: self.location.x},
      post_type: self.post_type,
      user: {
        first_name: self.user.first_name,
        last_name: self.user.last_name,
        avatar: self.user.avatar.url || "res://avatardefault",
        user_name: self.user.user_name,
        id: self.user.id.to_s
      }
    }
    post_hash[:caption] = self.caption if self.caption
    post_hash[:liked] = likes.flatten.include?(self.id.to_s) if likes && !likes.blank?
    return post_hash
  end

  private
  
  # def update_post_attributes
  #   if attachment.present? && attachment_changed?
  #     self.original_filename = attachment.file.original_filename
  #     self.content_type = attachment.file.content_type
  #   end
  # end

end