class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
      # response= creates an instance variable for whatever class its set to
      self.resource = User.find_for_database_authentication(email: user_params[:email])
      return invalid_login_attempt unless @user
      return invalid_login_attempt unless is_admin?(@user)
      return invalid_login_attempt unless @user.valid_password?(user_params[:password])
      set_flash_message!(:notice, :signed_in) 
      sign_in(resource_name, @user) 
      yield @user if block_given?
      respond_with @user, location: after_sign_in_path_for(@user)
  end

private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def is_admin?(user)
    user[:veritas_delite_admin]
  end

  def invalid_login_attempt
    set_flash_message!(:notice, :signed_in)
    redirect_to root_path
  end
end