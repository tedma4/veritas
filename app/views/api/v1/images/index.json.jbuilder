json.array!(@images) do |image|
  json.extract! image, :id, :original_filename
  json.url image_url(image, format: :json)
end
