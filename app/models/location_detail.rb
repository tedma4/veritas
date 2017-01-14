class LocationDetail
	include Mongoid::Document
	include Mongoid::Geospatial
	field :coords, type: Point, sphere: true
	field :time_stamp, type: DateTime
	field :area_id, type: String
	embedded_in :location
end