class AreasController < ApplicationController
	before_action :set_area, only: [:update, :delete, :show]

	def new
		if signed_in?
			@area = Area.new
			@areas = Area.pluck(:area_profile, :level, :title, :id).map { |area| 
				{ 
					coords: area[0][:coordinates][0].map {|points| {lat: points.last, lng: points.first} }, 
					level: area[1],
					title: area[2],
					id: area[3].to_s
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

	def show
		if signed_in?
			locs = UserLocation.where(:"coords" => {"$geoIntersects" => { "$geometry" => @area.area_profile } })
			@polygon = @area.to_a.map { |area| 
				{ 
					coords: area.area_profile[:coordinates][0].map {|points| {lat: points.last, lng: points.first} }, 
					level: area.level,
					title: area.title,
					id: area.id,
			  }
			}.first
			@dots = locs.pluck(:coords).map {|l| {position: {lat: l[1], lng: l[0]}, type: "user"} }
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
  	if signed_in?
	  	areas = Area.pluck(:area_profile, :title, :level, :id)
	  	@areas = areas.map {|area|
	  		{
	  			dot_count: UserLocation.where(:"coords" => {"$geoIntersects" => { "$geometry" => area[0] } }).count,
	  			title: area[1],
	  			level: area[2],
	  			id: area[3]
	  		}
	  	}
	  else
	  	redirect_to "/"
		end
  end

  def delete
  	@area.destroy
  end

	private

	def set_area
		@area = Area.find(params[:id])
	end

	def area_params
		the_params = params.require(:area).permit(:title, :area_profile, :level)
		the_params[:area_profile] = Area.profile_maker(params[:area][:area_profile])
		return the_params
	end
end