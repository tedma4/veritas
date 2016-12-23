# Rails.application.load_seed
require 'image_string'

# unless User.any? 
  40.times do |n|
    user = User.new
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
  	user.user_name = Faker::Internet.user_name
  	user.email = Faker::Internet.email
  	user.password =  'password'
  	user.password_confirmation =  'password'
    lat = Random.rand(33.319861..33.463984)
    long = Random.rand(-111.978976..-111.877226)
  	user.current_location = [long, lat]
    user.avatar = ImageString.image_file
    user.save(validate: false)
    user.create_pin
  end

  if User.where(:followed_users => []).any?
    User.where(:followed_users => []).each do |user|
      user.followed_users << User.all.to_a.sample(10).pluck(:id).map(&:to_s)
      user.followed_users.flatten!
      user.save
    end
  end
# # end
# # unless Post.any?
  91.times do |i|
    post = Post.new
    post.attachment = ImageString.image_file
    post.user_id = User.all.to_a.sample.id
    lat = Random.rand(33.319861..33.463984) # Random.rand(33.319861..33.463984)
    long = Random.rand(-111.978976..-111.877226) # Random.rand(-111.978976..-111.877226)
    post.location = [long, lat]
    post.save
  end

10.times do |i|
  note = Notification.new
  note.user_id = "3xmX4xyzDFvvkp"
  note.notified_by_id = User.all.to_a.sample.id.to_s
  note.notice_type = ["Sent Friend Request", "Signed Up With Your Pin"]
  note.save
end




# Bounding Box: Tempe 
# North Latitude: 33.463984
# South Latitude: 33.319861
# East Longitude: -111.877226
# West Longitude: -111.978976

# lat = Random.rand(33.319861..33.463984) # Random.rand(33.319861..33.463984)
# long = Random.rand(-111.978976..-111.877226) # Random.rand(-111.978976..-111.877226)
# [long, lat]


# Bounding Box: Phoenix
# North Latitude: 33.920570
# South Latitude: 33.290260
# East Longitude: -111.926046
# West Longitude: -112.324056

# end





# Notification.where(:notice_type => "friend request").each do |note| note.update_attributes(notice_type: "Sent Friend Request") end
# Notification.where(:notice_type => "pin signup").each do |note| note.update_attributes(notice_type: "Signed Up With Your Pin") end
# Notification.where(:notice_type => "accept request").count





