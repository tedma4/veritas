class Post
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
	mount_uploader :attachment, AttachmentUploader
	belongs_to :user, index: true
  has_many :notifications, dependent: :destroy  
  has_many :likes, dependent: :destroy

  # Validations
  # validates_presence_of :attachment
  # validates_integrity_of :post

  # Callbacks
  # before_save :update_post_attributes

  # Delegate
  delegate :url, :size, :path, to: :attachment

  # Virtual attributes
  alias_attribute :filename, :original_filename

  field :attached_item_id, type: Integer
  field :attached_item_type, type: String 
  field :attachment, type: String#, null: false
  field :original_filename, type: String
  field :content_type, type: String
  field :location, type: Geo::Point, index: true
  field :post_type, type: String, default: "public"
  field :selected_users, type: Array
  field :caption, type: String
  # validates :user_id, presence: true

  def build_post_hash
    post = {
      id: self.id,
      created_at: self.created_at,
      image: self.attachment.url || "/assets/images/default-image.png",
      location: self.location,
      post_type: self.post_type,
      user: {
        first_name: self.user.first_name,
        last_name: self.user.last_name,
        avatar: self.user.avatar.url || "/assets/images/default-image.png",
        user_name: self.user.user_name
      }
    }
    post[:caption] = self.caption if self.caption
  end

  private
  
  # def update_post_attributes
  #   if attachment.present? && attachment_changed?
  #     self.original_filename = attachment.file.original_filename
  #     self.content_type = attachment.file.content_type
  #   end
  # end

end