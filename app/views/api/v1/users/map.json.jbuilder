json.array!(@docs) do |user|
	json.extract! user
  json.extract! user, 'id', 'first_name', 'user_name'
  json.location user['current_location']['coordinates']
end
