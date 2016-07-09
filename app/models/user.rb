class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => "", uniq: true
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  has_many :images

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  field :first_name, :type => String
  field :last_name, :type => String
  field :user_name, :type => String, uniq: true
  field :current_location, type: Geo::Point, index: true

  def self.find_users_from_circle(current_user)
		NoBrainer.run { |r| circle1 = r.circle(current_user.current_location, 10, {:unit => 'mi'})
										r.table('users').get_intersecting(circle1, {:index => 'current_location'}).run(conn) }
  end
end

def add_location_to_users_and_images
	Image.each do |image|
		sample_location = (-180..180).to_a.sample(2)
		image.update_attributes(location: sample_location )
	end

	User.each do |user| 
		sample_location = (-180..180).to_a.sample(2)
		user.update_attribute	s(current_location: sample_location )
	end
end



