json.cache! post do
	json.id post.try(:id)
  json.url post_url(post)
  json.file_path post_path(post.try(:attachment))
end