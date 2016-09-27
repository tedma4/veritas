class Api::V1::NotificationsController < Api::V1::BaseController

	def index
		if params["user_id"]
			@notifications = Notification.where(user_id: params["user_id"])
			respond_with @notifications
		end
	end

end