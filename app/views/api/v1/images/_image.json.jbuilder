json.cache! image do
	json.id image.try(:id)
  json.url image_url(image)
  json.file_path image_path(image.try(:attachment))
end