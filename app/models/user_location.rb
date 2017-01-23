class UserLocation
	include Mongoid::Document
	include Mongoid::Geospatial
	field :coords, type: Point, sphere: true
	field :time_stamp, type: DateTime
	belongs_to :user, index: true, counter_cache: true
	# belongs_to :area, index: true
end