class Location
  include Mongoid::Document
	belongs_to :user, index: true
	embeds_many :location_details
end