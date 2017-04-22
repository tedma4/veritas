class Api::V1::ChatsController < Api::V1::BaseController
	
	def new
		@chat = Chat.new
	end

	def create
		@chat = Chat.create(chat_params)
		@chat.save
		$redis.lpush "users:#{@chat.id.to_s}", @chat.creator_id.to_s

	end

	def list_local_chats
		chats = Chat.where(location: {
				"$geoWithin" => {
					"$centerSphere": [params[:location], 15/3963.2]
				}
			})

		respond_with chats
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
		params.require(:chat).permit(:area, :creator, :title, :chat_type, :location)# , { users: [] }
	end
end