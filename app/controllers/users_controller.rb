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
    if signed_in?
      @area_watchers = AreaWatcher.where(user_id: @user.id)
    else
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
      location = UserLocation.pluck(:coords).map {|l| {position: {lat: l[1], lng: l[0]}, type: "user"} }
      post_hashes_not_nil = post.reject {|post| post == nil}
      post_hashes = post_hashes_not_nil.map {|p| {position: {lat: p[1], lng: p[0] }, type: "post" } }
      merge = post_hashes << location
      @posts = merge.flatten
      # @posts = Location.pluck(:location_details).flatten.map {|l| {position: {lat: l["coords"][1], lng: l["coords"][0]}, type: "user"} }
      respond_to do |format|
        format.html
        format.js
      end
    else
      redirect_to "/"
    end
  end
  
  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
    else
      @search = User.all.to_a.sample 50
    end
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
