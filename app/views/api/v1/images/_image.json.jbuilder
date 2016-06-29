json.cache! image do
	json.original_filename image.try(:original_filename)
	json.id image.try(:id)
end