class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

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
      if @user.update(user_params.to_h)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.where()
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def map

    # params[:current_location]
    #   # if params[:post]
    #   #   @docs = get_document(params[:current_location].split(',').map(&:to_f), params[:post])
    #   #   # @docs = posts.map(&:build_post_hash)
    #   # else
    #   # binding.pry
    #     this = get_document(params[:current_location].split(',').map(&:to_f))
    #     @docs = this.map(&:build_post_hash)
    #   # end
    # elsif
    # binding.pry
    if params[:user_id]
      user = User.where(:id => params[:user_id]).first
      # if params[:current_location]
      #   user.current_location = [params[:current_location][1], params[:current_location][0]]
      #   user.save
      # end
      # binding.pry
      @docs = user.get_followers_and_posts
    else
      @docs = get_document([Faker::Address.latitude.to_f, Faker::Address.longitude.to_f])
    end
    respond_with(@docs)
  end

  def get_document(location)
    # if post
      point = NoBrainer.run {|r| r.point(location[1], location[0])}
      posts = NoBrainer.run {|r| r.table('posts').get_nearest(point, {index: 'location', max_results: 50, unit: 'mi', max_dist: 5000} )}
      posts.map {|post| Post.find(post['doc']['id'])}
    # else
    #   point = NoBrainer.run {|r| r.point(location[1], location[0])}
    #   NoBrainer.run {|r| r.table('users').get_nearest(point, {index: 'current_location', max_results: 1, unit: 'mi', max_dist: 100} )}
    # end
  end

  def check_pin
    if params[:pin]
      if User.where(pin: params[:pin]).any?
        return true
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
          user = User.find(user["id"])
          build_search_hash(current_user, user)
        }
      else
        respond_with @search.map {|user| 
            user = User.find(user["id"])
            build_search_hash(user)
          }
      end
    else
      @search = User.sample 10
      respond_with @search
    end
  end

  def build_search_hash(current_user, user)
    {id: user.id,
     first_name: user.first_name,
     last_name: user.last_name,
     email: user.email,
     avatar: user.avatar.url,
     user_name: user.user_name,
     pin: user.pin,
     current_location: user.current_location,
     created_at: user.created_at,
     friendship_status: current_user.followed_users.include?(user.id) ? 
       "Is already a friend" : (user.pending_friends.include?(current_user.id) ? 
        "Request Sent" : "Send Request")
    }
  end

  def feed
    # binding.pry
    @user = User.where(id: params[:id]).first
    @feed = @user.get_followers_and_posts
    respond_with @feed

  end

  def send_request
    user = User.find(params["user_id"])
    user.send_friend_request(params["friend_id"]) unless user.followed_users.include?(params["friend_id"])
    friended_user = User.find(params["friend_id"])
    if friended_user.pending_friends.include?(user.id)
      render json: {status: :ok}
    else
      render json: {status: :unprocessable_entity}
    end
    user.send_friend_request_notification(params['friend_id'])
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :user_name, :password, :password_confiramtion, :current_location, :email, :pin, :avatar)
      #attachments_attributes: [:id, :attachment, :attachment_cache, :_destroy]
    end
end








