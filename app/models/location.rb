class Location
  include Mongoid::Document
  include Mongoid::Geospatial
	belongs_to :user, index: true
	embeds_many :location_details
end