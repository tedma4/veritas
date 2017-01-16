class AreasController < ApplicationController
	before_action :set_area, only: [:update]

	def new
		if signed_in?
			@area = Area.new
			# @areas = Area.in_start_location
		else
			redirect_to "/"
		end
	end

	def create
		params[:area_profile] = profile_maker(params[:area_profile])
		@area = Area.new(area_params)
		respond_to do |format|
			if @area.save
				## After an area is successfully saved add it to the corresponding 
				## location details
				# @area.add_id_to_location_details
				# @area.create_other_things
				format.json {render json: {status: 200}}
			else
				format.json {render json: @area.errors, status: :unprocessable_entity }
			end				
		end
	end

	def update
		respond_to do |format|
			if @area.update(area_params)
				## After an area is successfully saved add it to the corresponding 
				## location details
				# @area.update_location_details
				# @area.update_other_things
				format.json {render json: {status: 200}}
			else
				format.json {render json: @area.errors, status: :unprocessable_entity }
			end				
		end
  end

	private

	def profile_maker(area_profile)
	  # if the area_profile is a polygon
	  saved_hash = {type: "Polygon"}
	  if area_profile.count > 2
	  	shape = area_profile.map{|coords| coords.split(",").map(&:to_f).reverse}
	  	shape << shape.first
	  	saved_hash[:coordinates] = [shape]
	  else
	  	# if the area_profile is a rectangle
			north = area_profile.first.split(",").map(&:to_f)
			northWest = {lat: north.first, lng: north.last}
			south = area_profile.last.split(",").map(&:to_f)
			southEast = {lat: south.first, lng: south.last}
			northEast = {lat: northWest[:lat], lng: southEast[:lng] }
			southWest = {lat: southEast[:lat], lng: northWest[:lng] }

			# northWest, southWest, southEast, northEast, northWest
			shape = [
				[northWest[:lng], northWest[:lat]], 
				[southWest[:lng], southWest[:lat]], 
				[southEast[:lng], southEast[:lat]], 
				[northEast[:lng], northEast[:lat]], 
				[northWest[:lng], northWest[:lat]]
			]
	  	saved_hash[:coordinates] = [shape]
		end
	  return saved_hash
	end

	def set_area
		@area = Area.find(params(:area_id))
	end

	def area_params
		params.require(:areas).permit(:area_profile, :title)
	end
end