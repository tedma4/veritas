class Api::V1::ChatsController < Api::V1::BaseController
	
	def new
		@chat = Chat.new
	end

	def create
		@chat = Chat.create(chat_params)
		case params[:chat_type]
		when "private"
			@chat.save
		when "area"
			params[:title] = @chat.area.title + " Chat"
			@chat.save
		when "public"
			@chat.save
		end
	end

	def area_chats
		@area = Area.where(
			area_profil: {
				"$goeIntersects" => {
					"$geometry" => {
						type: "Point",
						coordinates: [params[:coords].last, params[:coords].first]
					}
				}
			},
			:level.nin => ["L0"],
			:level.in => ["L1", "L2"]
			)
		@area.chats
	end

	private

	def chat_params
		params.require(:chat).permit(:area, { users: [] }, :creator, :title, :chat_type)
	end
end