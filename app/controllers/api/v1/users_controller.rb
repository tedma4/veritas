class Api::V1::UsersController < ApplicationController
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
    @user = User.new(user_params)

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
      if @user.update(user_params)
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
      @docs = param_thing(params[:current_location].split(',').map(&:to_f), params[:area].split(",").map(&:to_i))
      # binding.pry
    elsif current_user.present? && params[:random] == 'false'
      @user = current_user
      @docs = get_box(@user, params[:area].split(",").map(&:to_i))
    else
      @user = User.sample
      @docs = get_box(@user, params[:area].split(",").map(&:to_i))
    end
  end

  def get_box(user = User.sample, args = [1,2])
    polygon_vertices = DistanceThing.new(user.current_location, args).box_coordinates
    # binding.pry
    box = NoBrainer.run { |r| r.polygon(r.args(polygon_vertices)) }
    NoBrainer.run { |r| r.table('users').filter {|row| row['current_location'].intersects(box) } }
  end

  def param_thing(location, area)#(location = [1.123456, 2.1234567], args = [1,2])
    # binding.pry
    polygon_vertices = DistanceThing.new(location, area).box_coordinates
    box = NoBrainer.run { |r| r.polygon(r.args(polygon_vertices)) }
    NoBrainer.run { |r| r.table('users').filter {|row| row['current_location'].intersects(box) } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :user_name)
      #attachments_attributes: [:id, :attachment, :attachment_cache, :_destroy]
    end
end