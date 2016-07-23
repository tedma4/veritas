class DistanceThing
	# Earth's radius in Mi
	EARTH_RADIUS = 3958.75586423

	# 1 deg lat ~68.70749821 miles
	# 1 deg long ~69.1710411*cos(latitude)

	def initialize(current_location = [33.4749038,-111.9775505], distance = [1,2])
		@lat = current_location[0]  # 33.4749038
		@long = current_location[1] # -111.9775505
		@disx = distance[0]         # 1
		@disy = distance[1]         # 2
	end

	def deg_lat(disx)
		(disx / EARTH_RADIUS) * (180 / Math::PI)
		# disx / 68.70749821
		# 2 * Math::PI * EARTH_RADIUS / 360
	end

	def deg_long(disy)
		(disy / EARTH_RADIUS) * (180 / Math::PI) / Math::cos(@lat * (Math::PI/180))
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