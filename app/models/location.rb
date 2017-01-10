class Location
  include Mongoid::Document
	belongs_to :user, index: true
	# belongs_to :area, index: true
	embeds_many :location_details
end