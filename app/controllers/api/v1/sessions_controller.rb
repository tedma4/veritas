class Api::V1::SessionsController < Api::V1::BaseController
  
#   skip_before_filter :authenticate_user_from_token!
#   respond_to :json
 
#   # @url /api/v1/sessions
#   # @action POST
#   #
#   # Create a new json web token
#   #
#   # @response [JsonWebToken] jwt token
#   #
#   def create
#     user = User.find_for_database_authentication(email: params[:user][:email])
#     if user && user.valid_password?(params[:user][:password])
#       auth_token = jwt_token(user)
#       respond_with do |format|
#         format.json { render json: {auth_token: auth_token} }
#       end
#     else
#       invalid_login_attempt
#     end
#   end
 
#   private
#   def invalid_login_attempt
#     render json: {error: t('devise.failure.not_found_in_database')}, status: :unauthorized
#   end
 
# end
# binding.pry
  skip_before_action :authenticate_user_from_token!
  before_action :ensure_params_exist

  def create
    @user = User.find_for_database_authentication(email: user_params[:email])
    return invalid_login_attempt unless @user
    return invalid_login_attempt unless @user.valid_password?(user_params[:password])
    # binding.pry
    @auth_token = jwt_token(@user)
    render json: {
      auth_token: @auth_token, 
      user: @user.build_user_hash,
      created_at: Time.now
    } 
    # binding.pry
    # respond_with(@auth_token)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def ensure_params_exist
    if user_params[:email].blank? || user_params[:password].blank?
      return render_unauthorized errors: { unauthenticated: ["Incomplete credentials"] }
    end
  end

  def invalid_login_attempt
    render_unauthorized errors: { unauthenticated: ["Invalid credentials"] }
  end
end