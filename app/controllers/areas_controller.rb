class AreasController < ApplicationController
	before_action :set_area, only: [:update]

	def new
		if signed_in?
			@area = Area.new
			@areas = Area.pluck(:area_profile, :level, :title).map { |area| 
				{ 
					coords: area[0][:coordinates][0].map {|points| {lat: points.last, lng: points.first}}, 
					level: area[1],
					title: area[2]
			  }
			}
			respond_to do |format|
				format.html
				format.js
			end
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
				# @area.update_other_things
				format.json {render json: {status: 200}}
			else
				format.json {render json: @area.errors, status: :unprocessable_entity }
			end				
		end
  end

  def index
  	@areas = Area.all
  end

	private

	def set_area
		@area = Area.find(params(:area_id))
	end

	def area_params
		the_params = params.require(:area).permit(:title, :area_profile, :level)
		the_params[:area_profile] = Area.profile_maker(params[:area][:area_profile])
		return the_params
	end
end