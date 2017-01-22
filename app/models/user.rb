class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic

  mount_uploader :avatar, AttachmentUploader
  after_create :friend_from_pin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,# :omniauthable, 
         :rememberable, :trackable, :validatable
  field :pin, type: String
  validates :pin, presence: true

  ## Database authenticatable
  field :email,              type: String, default: ""
  validates_uniqueness_of :email
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Delegate
  delegate :url, :size, :path, to: :avatar

  field :attached_item_id, type: Integer
  field :attached_item_type, type: String 
  field :avatar, type: String#, null: false
  field :original_filename, type: String

  # Virtual attributes
  alias_attribute :filename, :original_filename

  has_many :likes, dependent: :destroy
  has_many :posts, dependent: :destroy
  # has_one :location, dependent: :destroy
  has_many :notifications, dependent: :destroy  

  field :followed_users, type: Array, default: Array.new
  field :pending_friends, type: Array, default: Array.new

  validates_integrity_of  :avatar
  validates_processing_of :avatar
  validate :pin_exists, on: :create

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
  field :user_name, type: String#, uniq: true
  # field :current_location, type: Point, sphere: true

  def build_user_hash
    user = {id: self.id.to_s.to_s,
     first_name: self.first_name,
     last_name: self.last_name,
     email: self.email,
     avatar: self.avatar.url || "/assets/images/default-image.png",
     user_name: self.user_name,
     pin: self.pin,
     current_location: self.current_location,
     created_at: self.created_at
    }
    user[:like_count] = self.likes.count if self.likes
    return user
  end

  def send_friend_request(user_id)
    user = User.find(user_id)
    if user.pending_friends.nil? || user.pending_friends.empty?
      user.update_attributes(pending_friends: [self.id.to_s])
    else 
      unless user.pending_friends.include?(self.id.to_s)
        user.pending_friends << self.id.to_s
        user.save
      else
        puts "You already sent a request to #{user.first_name}"
      end
    end
  end

  def accept_friend_request(user_id)
    return if self.followed_users.include?(user_id)
    user = User.find(user_id)
    self.pending_friends.delete(user.id.to_s) if self.pending_friends.include?(user.id.to_s)
    if user.followed_users.nil? || user.followed_users.empty?
      user.update_attributes(followed_users: [self.id.to_s])
      if self.followed_users.nil? || self.followed_users.empty?
        self.update_attributes(followed_users: [user.id.to_s])
      else
        self.followed_users << user.id.to_s
        self.save
      end
    else
      user.followed_users << self.id.to_s
      user.save
      if self.followed_users.nil? || self.followed_users.empty?
        self.update_attributes(followed_users: [user.id.to_s])
      else
        self.followed_users << user.id.to_s
        self.save
      end
    end
  end

  def remove_user_from_pending_friends(user_id)
    return unless self.pending_friends.include?(user_id)
    self.pending_friends.delete(user_id)
    self.save
  end

  def unfriend_user(user_id)
    self.followed_users.delete(user_id)
    self.save
    @user = User.find(user_id)
    return unless @user.followed_users.include?(self.id.to_s)
    @user.followed_users.delete(self.id.to_s)
    @user.save
  end

  def create_pin
    pin_is_unique = nil
    until false
      pin = sudo_random_pin
      unless User.where(:pin => pin).any?
        pin_is_unique = pin
        break
      else
        puts "pin was #{pin}"
        false
      end
    end
    self.update_attributes(pin: pin_is_unique)
  end

  def sudo_random_pin
    letter = [('a'..'z').to_a, ('A'..'Z').to_a].flatten.shuffle.first
    numbers = (0..9).to_a.shuffle.first(3).join
    letter + numbers
  end

  def self.search(search)
    search = search.split(" ")
    if search.count == 1
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    else
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    end
  end

  def get_associates(type)
    case type
    when 'pending'
      User.where(:id.in => self.pending_friends).to_a
    when 'friend'
      User.where(:id.in => self.followed_users).to_a
    end
  end

  def get_followers_and_posts(*coords) # coords is an array of longitude and latitude
    likes = self.likes.to_a.pluck(:post_id).map(&:to_s)
    users = User.where(:id.in => self.followed_users)
    if !coords.blank?
      posts = Post.where(:location => 
        {"$within" => 
          {"$centerSphere" => [coords.flatten.map(&:to_f), (1.5.fdiv(3959) )]}
        },
        :user_id.in => users.to_a.pluck(:id),
        :post_type.nin => ["reply", "memory"]
        )
    else
      posts = Post.where(:user_id.in => users.to_a.pluck(:id))
    end

    posts.map {|post| 
      post.build_post_hash(likes)
    }
  end

  def send_friend_request_notification(user_id)
    return if user_id == self.id.to_s 
    Notification.create(user_id: user_id,
                        notified_by_id: self.id.to_s,
                        notice_type: "Sent Friend Request")
  end

  def accept_friend_request_notification(user_id)
    return if user_id == self.id.to_s 
    Notification.create(user_id: user_id,
                        notified_by_id: self.id.to_s,
                        notice_type: "Accepted Friend Request")
  end

  def signup_with_pin_notification(pin)
    user_id = User.where(:pin => pin).first.id.to_s
    return if user_id == self.id.to_s 
    Notification.create(user_id: user_id,
                        notified_by_id: self.id.to_s,
                        notice_type: "Signed Up With Your Pin")
  end

  # returns true of false if a post is likeed by user
  def like?(post)
    self.likes.where(post_id: post.id.to_s)
  end

  def self.add_location_data(user_id, coords, time_stamp)
    loc = UserLocation.new
    loc.user_id = user_id
    loc.coords = coords.split(",")
    loc.time_stamp = time_stamp
    loc.save(validate: false)
  end

  private

    def avatar_size_validation
      errors[:avatar] << "should be less than 500KB" if avatar.size > 100.5.megabytes
    end

    def pin_exists#(pin)
      errors.add(:pin, "#{self[:pin]} is Not a GoPost User Pin") unless User.where(pin: self[:pin]).any?
    end

    def friend_from_pin
      unless self.pin.nil?
        user_from_pin = User.where(pin: self[:pin]).first
        self.update_attributes(followed_users: [user_from_pin.id.to_s])
        if user_from_pin.followed_users.nil? || user_from_pin.followed_users.empty?
          user_from_pin.update_attributes(followed_users: [self.id.to_s])
        else
          user_from_pin.followed_users << self.id.to_s
          user_from_pin.save
        end
      else
        return true
      end
    end

end