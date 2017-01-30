class Api::V1::NotificationsController < Api::V1::BaseController
  # skip_before_action :authenticate_user_from_token!
	def index
		if @current_user
			notes = Notification.where(user_id: @current_user.id)
			@notifications = notes.map(&:build_notification_hash)
			respond_with @notifications
		end
	end
end