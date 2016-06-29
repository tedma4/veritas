class Image
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
	mount_uploader :attachment, AttachmentUploader
	# belongs_to :user, polymorphic: true

  # Validations
  # validates_presence_of :attachment
  # validates_integrity_of :image

  # Callbacks
  # before_save :update_image_attributes

  # Delegate
  delegate :url, :size, :path, to: :attachment

  # Virtual attributes
  alias_attribute :filename, :original_filename

  field :attached_item_id, :type => Integer
  field :attached_item_type, :type => String 
  field :attachment, :type => String#, null: false
  field :original_filename, :type => String
  field :content_type, :type => String

  private
  
  # def update_image_attributes
  #   if attachment.present? && attachment_changed?
  #     self.original_filename = attachment.file.original_filename
  #     self.content_type = attachment.file.content_type
  #   end
  # end

end