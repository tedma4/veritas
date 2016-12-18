class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
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
    @auth_token = jwt_token(@user)
    respond_to do |format|
      if @user.save
        @user.create_pin
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: { auth_token: @auth_token, user: @user.build_user_hash, created_at: @user.created_at } }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(user_params.to_h)
        format.json { render json: @user.build_user_hash, status: :ok }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def map
    if params[:user_id]
      user = User.includes(:likes).where(:id => params[:user_id]).first
      @docs = user.get_followers_and_posts
    else
      @docs = get_document([Faker::Address.latitude.to_f, Faker::Address.longitude.to_f])
    end
    respond_with(@docs)
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
    user = User.find(params[:id])
    list = User.where(:id.in => user.followed_users)
    @users = list.map &:build_user_hash
    respond_with(@users)
  end

  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
      if params["user_id"]
        current_user = User.find(params["user_id"])
        respond_with @search.map {|user| 
          # user = User.find(user["id"])
          build_search_hash(user, current_user)
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
     current_location: user.current_location,
     created_at: user.created_at
    }
    if current_user
      user_hash[:friendship_status] = current_user.followed_users.include?(user.id.to_s) ? 
         "Is already a friend" : (user.pending_friends.include?(current_user.id.to_s) ? 
          "Request Sent" : "Send Request")
    end
    user_hash[:like_count] = user.likes.count if user.likes
    return user_hash
  end

  def feed
    @user = User.includes(:likes).where(id: params[:id]).first
    @feed = @user.get_followers_and_posts
    respond_with @feed

  end

  def send_request
    user = User.find(params["user_id"])
    user.send_friend_request(params["friend_id"]) unless user.followed_users.include?(params["friend_id"])
    friended_user = User.find(params["friend_id"])
    if friended_user.pending_friends.include?(user.id.to_s)
      render json: {status: :ok}
    else
      render json: {status: :unprocessable_entity}
    end
    user.send_friend_request_notification(params['friend_id'])
  end

  def approve_friend_request
    user = User.find(params["user_id"])
    user.accept_friend_request(params['friend_id'])
    user.accept_friend_request_notification(params['friend_id'])
  end

  def remove_friend
    user = User.find(params["user_id"])
    user.unfriend_user(params['friend_id'])
  end

  def decline_friend_request
    user = User.find(params["user_id"])
    user.remove_user_from_pending_friends(params['friend_id'])
  end

  def accept_requests
    user = User.find(params[:id])
    @users = User.where(:id.in => user.pending_friends)
  end

  def memories
    # "http://localhost:3000/v1/memories?user_id=user_id"
    # Gettting the users the current user selected
    current_user = User.find(params[:user_id])
    user_ids_the_current_user_selected = Post.where(post_type: "memory", user_id: current_user.id).to_a.pluck(:selected_users).flatten.uniq
    # Getting the users that selected the current user
    users_that_selected_the_current_user = Post.where(post_type: "memory", :selected_users.include => current_user.id.to_s).to_a.pluck(:user_id)
    all = user_ids_the_current_user_selected  << users_that_selected_the_current_user
    list = all.flatten.uniq
    people = User.where(:id.in => list)
    @users = people.map &:build_user_hash
    respond_with(@users)
  end

  def get_memories
    # http://localhost:3000/get_memories?user_id=user_id&friend_id=friend_id
    current_user_posts = Post.where(post_type: "memory", user_id: params[:user_id], :selected_users.include => params[:friend_id]).to_a.pluck(:id).map(&:to_s)
    friend_posts = Post.where(post_type: "memory", user_id: params[:friend_id], :selected_users.include => params[:user_id]).to_a.pluck(:id).map(&to_s)
    all_posts = current_user_posts << friend_posts
    posts = Post.where(:id.in => all_posts.flatten)
    @posts = posts.flatten.map &:build_post_hash
    respond_with @posts
  end


  private

  def delete_notification
    Notification.find(params["notification_id"]).destroy
  end

  def set_user
    @user = User.find(params[:id])
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
    the_params[:avatar] = parse_user_data(the_params[:avatar]) if the_params[:avatar]
    the_params.delete_if {|k, v| v == nil}
    return the_params
  end

  def parse_user_data(base64_user)
    filename = "upload-user"
    # in_content_type, encoding, string = base64_user.split(/[:;,]/)[0..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(base64_user)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
                                               tempfile: @tempfile,
                                               content_type: content_type,
                                               filename: filename
                                           })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
end








