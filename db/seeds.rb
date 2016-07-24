# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# new_users = [
# 	{name: 'BillyBob', user_name: 'bob'},
# 	{name: 'John Ceh', user_name: 'John'},
# 	{name: 'Miguel Ocana', user_name: 'smegal'},
# 	{name: 'David Fuka', user_name: 'graveto'},
# 	]
# 	new_users.each do |user|
# 		User.create(name: user[:name], user_name: user[:user_name])
# 	end
# password = 'password'
unless User.any?
  200.times do |n|
    user = User.new
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
  	user.user_name = Faker::Internet.user_name
  	user.email = Faker::Internet.email
  	user.password =  'password'
  	user.password_confirmation =  'password'
  	user.current_location = [Faker::Address.longitude, Faker::Address.latitude] 
    user.remote_avatar_url = Faker::Placeholdit.image
    user.save
  end
end
unless Image.any?
  200.times do |i|
    image = Image.new
    image.remote_attachment_url = Faker::Placeholdit.image
    image.user_id = User.sample.id
    image.location = [Faker::Address.longitude, Faker::Address.latitude]
    image.save
  end
end








