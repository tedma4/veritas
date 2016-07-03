json.array!(@images) do |image|
  json.extract! image, :id
  json.url image_url(image[:attachment])
  json.file_path image.try(:attachment).url
end
