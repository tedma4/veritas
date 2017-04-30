class Api::V1::ChatsController < Api::V1::BaseController
  require 'string_image_uploader'
	
	def new
		@chat = Chat.new
	end

	def create
		@chat = Chat.create(chat_params)
		@chat.save
		respond_with @chat.build_chat_hash
		# $redis.lpush "users:#{@chat.id.to_s}", @chat.creator_id.to_s

	end

	def list_local_chats
		@chats = Chat.where(location: {
				"$geoWithin" => {
					"$centerSphere": [params[:location], 15/3963.2]
				}
			})

		respond_with @chats.map(&:build_chat_hash)

		# $redis.smembers "users:#{chats.first.id}"
		# @area = Area.where(
		# 	area_profil: {
		# 		"$goeIntersects" => {
		# 			"$geometry" => {
		# 				type: "Point",
		# 				coordinates: [params[:coords].last, params[:coords].first]
		# 			}
		# 		}
		# 	},
		# 	:level.nin => ["L0"],
		# 	:level.in => ["L1", "L2"]
		# 	)
		# @area.chats
	end

	private

	def chat_params
		the_params = params.require(:chat).permit(:area, :creator, :title, :chat_type, :location, :cover)# , { users: [] }
		the_params[:cover] = StringImageUploader.new(the_params[:cover], 'chat') if the_params[:cover]
	end
end