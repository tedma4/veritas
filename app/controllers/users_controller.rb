class UsersController < ApplicationController
  require 'distance'
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    if signed_in?
      @users = User.all.order_by(:id => :desc)
    else
      redirect_to "/users/sign_in"
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !signed_in?
      redirect_to "/users/sign_in"
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    if !signed_in?
      redirect_to "/users/sign_in"
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.to_h)
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
    if signed_in?
      if params[:user].present? && params[:time].present?
        if params[:time].include?(",")
          date_array = params[:time].split(",")
          date = (Date.parse(date_array.first)..Date.parse(date_array.last))
        else
          date = (Date.parse(params[:time])..Date.today)
        end
        post = Post.between(created_at: date).union.in(user_id: params[:user].split(",")).pluck(:location)
      elsif params[:time].present? && !params[:user].present?
        if params[:time].include?(",")
          date_array = params[:time].split(",")
          date = (Date.parse(date_array.first)..Date.parse(date_array.last))
        else
          date = (Date.parse(params[:time])..Date.today)
        end
        post = Post.between(created_at: date).pluck(:location)
      elsif params[:user]
        post = Post.in(user_id: params[:user].split(",")).pluck(:location)
      else
        post = Post.all.limit(250).pluck(:location)
      end
      @posts = post.map {|p| [p[1], p[0]] }
    else
      redirect_to "users/sign_in"
    end

    respond_to do |format|
      format.html
      format.js
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
      @search = User.all.to_a.sample 50
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

  def accept_requests
    user = User.find(params[:id])
    @users = User.where(:id.in => user.pending_friends)
  end

  def friends_posts
    user = User.find(params[:id])
    posts = User.where(:id.in => user.followed_users.flatten).map {|user| user.posts.to_a }
    @posts = posts.flatten.sort {|a, b| b['created_at'] <=> a['created_at']}
  end

  def friend_list
    user = User.find(params[:id])
    @users = User.where(:id.in => user.followed_users)
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
