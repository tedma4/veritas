class LocationDetail
	include Mongoid::Document
	include Mongoid::Geospatial
  field :coords, type: Point
  spatial_index :coords
	field :time_stamp, type: DateTime
	embedded_in :location
end