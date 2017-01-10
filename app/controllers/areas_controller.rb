class AreasController < ApplicationController

	def new
		if signed_in?
		else
			redirect_to "/"
		end
	end
end