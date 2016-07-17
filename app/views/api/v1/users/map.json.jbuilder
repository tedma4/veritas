json.array!(@docs) do |user|
  json.extract! user
  json.extract! user['doc'], 'id', 'first_name', 'user_name'
  json.location user['doc']['current_location']['coordinates']
end
