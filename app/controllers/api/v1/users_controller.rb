class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_create :pin_exists
  after_create :friend_from_pin

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
    if params[:current_location]
      @docs = get_document(params[:current_location].split(',').map(&:to_f))
    else
      @docs = get_document([Faker::Address.latitude.to_f, Faker::Address.longitude.to_f])
    end
    respond_with(@docs)
  end

  def get_document(location)
    point = NoBrainer.run {|r| r.point(location[1], location[0])}
    NoBrainer.run {|r| r.table('users').get_nearest(point, {index: 'current_location', max_results: 250, unit: 'mi', max_dist: 5000} )}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :user_name, :email, :password)
      #attachments_attributes: [:id, :attachment, :attachment_cache, :_destroy]
    end

    def pin_exists
      if params[:pin]
        User.where(pin: params[:pin]).any?
      else
        raise 'Not a GoPost User Pin'
      end
    end

    def friend_from_pin
      user_from_pin = User.where(pin: params[:pin]).first
      @user.update_attributes(followed_users: [user.id])
      if user_from_pin.followed_users.nil? || user_from_pin.followed_users.empty?
        user_from_pin.update_attributes(followed_users: [@user.id])
      else
        user_from_pin.followed_users << @user.id
        user_from_pin.save
      end
    end
end








