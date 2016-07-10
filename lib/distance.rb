class DistanceThing
	# Earth's radius in Mi
	# EARTH_RADIUS = 3958.75586423

	# 1 deg lat ~68.70749821 miles
	# 1 deg long ~69.1710411*cos(latitude)

	def initialize(current_location, distance)
		@lat = current_location[1]
		@long = current_location[0]
		@disx = distance[0]
		@disy = distance[1]
	end

	def deg_lat(disx)
		disx / 68.70749821
		# 2 * Math::PI * EARTH_RADIUS / 360
	end

	def deg_long(disy)
		69.1710411*Math::cos(deg_lat(disy))
		 # * Math.cos(lat)
	end

	def box_coordinates
		[
			[@long + deg_long(@disy), @lat - deg_lat(@disx)],
			[@long + deg_long(@disy), @lat + deg_lat(@disx)],
			[@long - deg_long(@disy), @lat + deg_lat(@disx)],
			[@long - deg_long(@disy), @lat - deg_lat(@disx)]
		]
	end
end