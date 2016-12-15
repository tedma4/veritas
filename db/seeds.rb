# Rails.application.load_seed
require 'image_string'

# unless User.any? 
  4.times do |n|
    user = User.new
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
  	user.user_name = Faker::Internet.user_name
  	user.email = Faker::Internet.email
  	user.password =  'password'
  	user.password_confirmation =  'password'
  	user.current_location = [Faker::Address.longitude, Faker::Address.latitude] 
    user.avatar = ImageString.image_file
    user.save(validate: false)
    user.create_pin
  end

  # if User.where(:followed_users => []).any?
  #   User.where(:followed_users => []).each do |user|
  #     user.followed_users << User.all.to_a.sample(10).pluck(:id)
  #     user.followed_users.flatten!
  #     user.save
  #   end
#   end
# # end
# # unless Post.any?
  9.times do |i|
    post = Post.new
    post.attachment = ImageString.image_file
    post.user_id = User.all.to_a.sample.id.to_s
    post.location = [Faker::Address.longitude, Faker::Address.latitude]
    post.save
  end

# 10.times do |i|
#   note = Notification.new
#   note.user_id = "3xmX4xyzDFvvkp"
#   note.notified_by_id = User.all.to_a.sample.id.to_s
#   note.notice_type = "Sent Friend Request"
#   note.save
# end

# end





# Notification.where(:notice_type => "friend request").each do |note| note.update_attributes(notice_type: "Sent Friend Request") end
# Notification.where(:notice_type => "pin signup").each do |note| note.update_attributes(notice_type: "Signed Up With Your Pin") end
# Notification.where(:notice_type => "accept request").count
# Notification.where(:notice_type => "accept request").count





