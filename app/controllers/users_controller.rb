class UsersController < ApplicationController
  require 'distance'
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
    # binding.pry
    respond_to do |format|
      if @user.save
        @user.signup_with_pin_notification(@user.pin)
        @user.create_pin
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
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
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def map
    if params[:current_location]
      @docs = param_thing(params[:current_location].split(',').map(&:to_f))
    else
      @docs = get_document([Faker::Address.latitude.to_f, Faker::Address.longitude.to_f])
    end
  end

  def get_document(location)
    point = NoBrainer.run {|r| r.point(location[1], location[0])}
    NoBrainer.run {|r| r.table('users').get_nearest(point, {index: 'current_location', max_results: 25, unit: 'mi', max_dist: 100} )}
  end

  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
    else
      @search = User.sample 50
    end
  end

  def send_request
    current_user.send_friend_request(params['user'])
    current_user.send_friend_request_notification(params['user'])
  end

  def approve_request
    current_user.accept_friend_request(params['user'])
    current_user.accept_friend_request_notification(params['user'])
  end

  def remove_friend
    current_user.unfriend_user(params['user'])
  end

  def decline_request
    current_user.decline_friend_request(params['user'])
  end

  def friend_list
    user = User.find(params[:id])
    @users = User.where(:id.in => user.followed_users)
  end

  def accept_requests
    user = User.find(params[:id])
    @users = User.where(:id.in => user.pending_friends)
  end

  def friends_posts
    user = User.find(params[:id])
    posts = User.where(:id.in => user.followed_users.flatten).map {|user| user.posts.to_a }
    @posts = posts.flatten.sort {|a, b| b['created_at'] <=> a['created_at']}
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
