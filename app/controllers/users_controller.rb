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

    respond_to do |format|
      if @user.save
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
    if current_user.present? && params[:random] == 'false'
      @user = current_user
      @docs = get_docs(@user, params[:area].to_i)
    else
      @user = User.sample
      @docs = get_docs(@user, params[:area].to_i)
    end
  end

  def get_docs(user, *area)
    if area[0] != 0
      circle1 = NoBrainer.run { |r| r.circle(user.current_location.to_a, area[0], {:unit => 'mi'}) }
      NoBrainer.run { |r| r.table('users').filter {|row| row['current_location'].intersects(circle1)} }
    else
      circle1 = NoBrainer.run { |r| r.circle(user.current_location.to_a, 10, {:unit => 'mi'})}
      NoBrainer.run { |r| r.table('users').filter {|row| row['current_location'].intersects(circle1)} }
    end
  end

  def get_box(user, args)
    polygon_vertices = DistanceThing.new(user.current_location, args).box_coordinates
    box = NoBrainer.run { |r| r.polygon(r.args(polygon_vertices)) }
    @docs = NoBrainer.run { |r| r.table('users').filter {|row| row['current_location'].intersects(box) } }
  end








  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :user_name, :password, :password_confiramtion, :current_location, :email)
      #attachments_attributes: [:id, :attachment, :attachment_cache, :_destroy]
    end
end
