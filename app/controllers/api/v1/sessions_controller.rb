class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
  before_action :ensure_params_exist

  def create
    @user = User.find_for_database_authentication(email: user_params[:email])
    return invalid_login_attempt unless @user
    return invalid_login_attempt unless @user.valid_password?(user_params[:password])
    if Session.where(user_id: @user.id).any?
      session = Session.where(user_id: @user.id).first
    else
      session = Session.new(user_id: @user.id)
      session.save
    end
    jwt_user_hash = {session_id: session.id.to_s}
    auth_token = jwt_token(jwt_user_hash)
    render json: {
      auth_token: auth_token, 
      user: @user.build_user_hash,
      created_at: Time.now
    }
  end

  def destroy
    session = JsonWebToken.decode(request.header["HTTP_AUTHORIZATION"])[:session_id]
    Session.find(session).destroy
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
    self.status = :unauthorized
    self.response_body = { error: 'Access denied' }

    # render_unauthorized errors: { unauthenticated: ["Invalid credentials"] }
  end
end