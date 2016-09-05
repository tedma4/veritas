# unless User.any? 
  200.times do |n|
    user = User.new
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
  	user.user_name = Faker::Internet.user_name
  	user.email = Faker::Internet.email
  	user.password =  'password'
  	user.password_confirmation =  'password'
  	user.current_location = [Faker::Address.longitude, Faker::Address.latitude] 
    user.remote_avatar_url = Faker::Avatar.image
    # user.validate = false
    user.save(validate: false)
  end

  if User.where(:followed_users.eq => []).any?
    User.where(:followed_users.eq => []).each do |user|
      user.followed_users << User.sample(10).pluck(:id)
      user.followed_users.flatten!
      user.save
    end
  end
# end
# unless Post.any?
  800.times do |i|
    post = Post.new
    post.remote_attachment_url = Faker::Avatar.image
    post.user_id = User.sample.id
    post.location = [Faker::Address.longitude, Faker::Address.latitude]
    post.save
  end
# end











