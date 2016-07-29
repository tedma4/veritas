class Api::V1::FriendshipsController < Api::V1::BaseController  
  #This ensures that a user must be logged in to follow/unfollow a user
  before_action :signed_in_user

  def create
    #This allows a user to follow another user
    unless @_env['HTTP_REFERER'].include?('feed' && 'users')
      Friendship.public_activity_off
    end
    @user = @_env['HTTP_REFERER'].include?('feed' && 'users') ?
        User.find(params[:friendship][:followed_id]) :
        Page.find(params[:friendship][:followed_id])
    current_user.follow!(@user)
    #@user ? current_user.follow!(@user) : current_user.follow!(@page)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    #This allows a user to unfollow a user they are following
    @user = Friendship.find(params[:id])#.followed #Idk if removing this will break anything, but it shouldn't since I added the follow type to the unfollow method
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end