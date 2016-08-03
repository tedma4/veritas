class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  mount_uploader :avatar, AttachmentUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: "", uniq: true
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time
  field :pin, type: String

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Delegate
  delegate :url, :size, :path, to: :avatar

  # Virtual attributes
  alias_attribute :filename, :original_filename

  field :attached_item_id, type: Integer
  field :attached_item_type, type: String 
  field :avatar, type: String#, null: false
  field :original_filename, type: String

  # field :private_account,    type: Boolean, default: false
  has_many :posts

  field :followed_users, type: Array
  field :pending_friends, type: Array

  validates_integrity_of  :avatar
  validates_processing_of :avatar

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  field :first_name, type: String
  field :last_name, type: String
  field :user_name, type: String, uniq: true
  field :current_location, type: Geo::Point, index: true

  def build_user_hash
    {id: self.id,
     first_name: self.first_name,
     last_name: self.last_name,
     email: self.email,
     avatar: self.avatar.url,
     user_name: self.user_name,
     created_at: self.created_at
    }
  end

  def send_friend_request!(user)
    if user.pending_friends.nil? || user.pending_friends.empty?
      user.update_attributes(pending_friends: [self.id])
    else 
      unless user.pending_friends.include?(self.id)
        user.pending_friends << self.id
        user.save
      else
        puts "You already sent a request to #{user.first_name}"
      end
    end
  end

  def accept_friend_request(user)
    self.pending_friends.delete(user.id)
    if user.followed_users.nil? || user.followed_users.empty?
      user.update_attributes(followed_users: [self.id])
      if self.followed_users.nil? || self.followed_users.empty?
        self.update_attributes(followed_users: [user.id])
      else
        self.followed_users << user.id
        self.save
      end
    else
      user.followed_users << self.id
      user.save
      if self.followed_users.nil? || self.followed_users.empty?
        self.update_attributes(followed_users: [user.id])
      else
        self.followed_users << user.id
        self.save
      end
    end
  end

  def decline_friend_request(user_id)
    self.pending_friends.delete(user_id)
  end

  def unfriend_user(user_id)
    self.followed_users.delete(user_id)
    @user = User.where(id: user_id).first
    @user.followed_users.delete(self.id)
  end

  def create_pin
    letter = [('a'..'z').to_a, ('A'..'Z').to_a].flatten.shuffle.first
    numbers = (0..9).to_a.shuffle.first(3).join
    sudo_random_pin = letter + numbers
    self.update_attributes(pin: sudo_random_pin)
  end



  private
  
  def avatar_size_validation
    errors[:avatar] << "should be less than 500KB" if avatar.size > 100.5.megabytes
  end

end