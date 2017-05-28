class Api::V1::UsersController < Api::V1::BaseController
  # skip_before_action :authenticate_user_from_token!
  require 'string_image_uploader'
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  after_action :delete_notification, only: [:approve_friend_request, :decline_friend_request]

  # GET /users
  # GET /users.json
  def index
    @users = User.all.order_by(:id => :desc)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.to_h)
    @auth_token = jwt_token({user_id: @user.id.to_s})
    respond_to do |format|
      if @user.save
        @user.create_pin
        format.json { render json: { auth_token: @auth_token, user: @user.build_user_hash, created_at: @user.created_at } }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @current_user.update_attributes(user_params.to_h)
        format.json { render json: @user.build_user_hash, status: :ok }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @current_user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def get_document(location)
    Post.near(location: [location[1], location[0]]).max_distance(location: 50)
  end

  def check_pin
    if params[:pin]
      if User.where(pin: params[:pin]).any?
        render json: {status: 200}
      else
        raise 'Access denied'
      end
    end
  end

  def friend_list
    # user = User.find(params[:id])
    list = User.where(:id.in => @current_user.followed_users)
    @users = list.map &:build_user_hash
    respond_with(@users)
  end

  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
      if @current_user
        respond_with @search.map {|user| 
          user = User.find(user["id"])
          build_search_hash(user, @current_user)
        }
      else
        respond_with @search.map {|user| 
            # user = User.find(user["id"])
            build_search_hash(user)
          }
      end
    else
      @search = nil
      respond_with @search
    end
  end

  def build_search_hash(user, *current_user)
    user_hash = {id: user.id.to_s,
     first_name: user.first_name,
     last_name: user.last_name,
     email: user.email,
     avatar: user.avatar.url,
     user_name: user.user_name,
     pin: user.pin,
     created_at: user.created_at
    }
    if !current_user.blank?
      user_hash[:friendship_status] = current_user.first.followed_users.include?(user.id.to_s) ? 
         "Is already a friend" : (user.pending_friends.include?(current_user.first.id.to_s) ? 
          "Request Sent" : "Send Request")
    end
    user_hash[:like_count] = user.likes.count if user.likes
    return user_hash
  end

  def send_request
    # user = User.find(params["user_id"])
    @current_user.send_friend_request(params["friend_id"]) unless @current_user.followed_users.include?(params["friend_id"])
    friended_user = User.find(params["friend_id"])
    if friended_user.pending_friends.include?(@current_user.id.to_s)
      render json: {status: :ok}
    else
      render json: {status: :unprocessable_entity}
    end
    @current_user.send_friend_request_notification(params['friend_id'])
  end

  def approve_friend_request
    # user = User.find(params["user_id"])
    @current_user.accept_friend_request(params['friend_id'])
    @current_user.accept_friend_request_notification(params['friend_id'])
  end

  def remove_friend
    # user = User.find(params["user_id"])
    @current_user.unfriend_user(params['friend_id'])
  end

  def decline_friend_request
    # user = User.find(params["user_id"])
    @current_user.remove_user_from_pending_friends(params['friend_id'])
  end

  def accept_requests
    # user = User.find(params[:id])
    @users = User.where(:id.in => @current_user.pending_friends)
  end

  def memories
    # "http://localhost:3000/v1/memories?user_id=user_id"
    user_ids_the_current_user_selected = Post.where(post_type: "memory", user_id: @current_user.id).to_a.pluck(:selected_users).flatten.uniq
    # Getting the users that selected the current user

    users_that_selected_the_current_user = Post.where(post_type: "memory", :selected_users.in => [@current_user.id.to_s]).to_a.pluck(:user_id)
    all = user_ids_the_current_user_selected  << users_that_selected_the_current_user
    list = all.flatten.uniq
    people = User.where(:id.in => list)
    @users = people.map &:build_user_hash
      respond_with(@users)
  end

  def get_memories
    # http://localhost:3000/get_memories?user_id=user_id&friend_id=friend_id
    current_user_posts = Post.where(post_type: "memory", user_id: @current_user.id, :selected_users.in => [params[:friend_id]]).to_a.pluck(:id).map(&:to_s)
    friend_posts = Post.where(post_type: "memory", user_id: params[:friend_id], :selected_users.in => [@current_user.id.to_s]).to_a.pluck(:id).map(&:to_s)
    all_posts = current_user_posts << friend_posts
    posts = Post.where(:id.in => all_posts.flatten)
    @posts = posts.flatten.map &:build_post_hash
      respond_with @posts
  end

  def user_location
    # http://localhost:3000/v1/user_location?user_id=5856d773c2382f415081e8cd&location=-111.97798311710358,33.481907631522525&time_stamp=2017-01-15T18:01:24.734-07:00    
    if @current_user
      coords = User.add_location_data(@current_user.id, params[:location], params[:time_stamp])
      @current_user.area_watcher(coords)
      render json: {status: 200} #, auth_token: encoded_token}
    else
      render json: {errors: 400}
    end
  end

  def map
    # Earth Radius in miles = 3959
    # http://localhost:3000/v1/map?user_id=5856d773c2382f415081e8cd&location=-111.97798311710358,33.481907631522525&time_stamp=2017-01-15T18:01:24.734-07:00 
    if @current_user
      # user = User.includes(:likes).where(:id => @current_user).first
      @docs = @current_user.get_followers_and_posts(params[:location].split(","))
      coords = User.add_location_data(@current_user.id, params[:location], params[:time_stamp])
      @current_user.area_watcher(coords)
    else
      @docs = get_document([Faker::Address.latitude.to_f, Faker::Address.longitude.to_f])
    end
    respond_with(@docs)
  end

  def get_joined_chats
    @chats = Chat.where(:id.in => @current_user.joined_chats)
    if @chats.any?
      respond_with(@chats.map(&:build_chat_hash) ) 
    else
      respond_with([])
    end
  end

  def join_chat
    user = @current_user 
    user.joined_chats << params[:chat_id] unless user.joined_chats.include?(params[:chat_id])
    if user.save
      render json: {status: 200}
    else
      render json: {error: "User already joined"}
    end
  end

  def leave_chat
    user = @current_user
    user.joined_chats.delete(params[:chat_id]) if user.joined_chats.include?(params[:chat_id])
    if user.save
      render json: {status: 200}
    else
      render json: {error: "User already joined"}
    end
  end


  def feed
    # @user = User.includes(:likes).where(id: params[:id]).first
    @feed = @current_user.get_followers_and_posts
    respond_with @feed
  end

  private

  def delete_notification
    Notification.find(params["notification_id"]).destroy
  end
  
  def user_params
    the_params = params.require(:user).permit(:first_name, :last_name, :user_name, :password, :password_confirmation, :current_location, :email, :pin, :avatar)
    the_params[:first_name] = params[:user][:first_name]
    the_params[:last_name] = params[:user][:last_name]
    the_params[:user_name] = params[:user][:user_name]
    the_params[:password] = params[:user][:password]
    the_params[:password_confirmation] = params[:user][:password_confirmation]
    the_params[:current_location] = params[:user][:current_location]
    the_params[:email] = params[:user][:email]
    the_params[:pin] = params[:user][:pin]
    the_params[:avatar] = StringImageUploader.new(the_params[:avatar], "User").parse_image_data if the_params[:avatar]
    the_params.delete_if {|k, v| v == nil}
    return the_params
  end

  def set_user
    @user = @current_user
  end
end








