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
		@area = Area.new(area_params)
		respond_to do |format|
			if @area.save
				## After an area is successfully saved add it to the corresponding 
				## location details
				# @area.add_to_location_details
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

	def set_area
		@area = Area.find(params(:area_id))
	end

	def area_params
		params.require(:areas).permit(:area_profile, :title)
	end
end