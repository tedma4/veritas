 class Api::V1::ChatsController < Api::V1::BaseController
  require 'string_image_uploader'
	
	def new
		@chat = Chat.new
	end

	def create
		params[:chat][:creator_id] = @current_user.id
		@chat = Chat.create(chat_params)
		area = @chat.inside_area?('L2')
		if area.any?
			@chat.area_id = area.first.id
			@chat.chat_type = "AreaChat"
		end
		@chat.save
		render json: @chat.build_chat_hash
		# $redis.lpush "users:#{@chat.id.to_s}", @chat.creator_id.to_s

	end

	def index
		if params[:chat_list]
			@chats = Chat.includes(:messages).where(:id.in => params[:chat_list])
		else
			@chats = Chat.all 
		end
		render json: @chats.map(&:build_chat_hash)
	end

	def list_local_chats
		area_chats = @current_user.inside_an_area?(params[:location].split(",").map(&:to_f))
		@chats = []
		if area_chats.first && area_chats.last.level == "L2"
			@chats << area_chats.last.chats
		end
			@chats << Chat.includes(:messages).where(
				location: {
					"$geoWithin" => {
						"$centerSphere": [params[:location].split(",").map(&:to_f), 15/3963.2]
					}
				},
				:creator_id.nin => [@current_user.id],
				:area => nil
			).to_a
		respond_with @chats.flatten.map(&:build_chat_hash) if @chats

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
		the_params = params.require(:chat).permit(:area_id, :creator_id, :title, :chat_type, :location, :cover)# , { users: [] }
		the_params[:cover] = StringImageUploader.new(the_params[:cover], 'chat').parse_image_data if the_params[:cover]
		the_params[:location] = params[:chat][:location] if params[:chat][:location]
		the_params[:creator_id] = params[:chat][:creator_id] if params[:chat][:creator_id]
		the_params
	end
end