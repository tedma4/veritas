json.array!(@posts) do |post|
  json.extract! post, :id
  json.url post_url(post[:attachment])
  json.file_path post.try(:attachment).url
end
