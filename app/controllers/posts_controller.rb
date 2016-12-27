class PostsController < ApplicationController
  before_action :set_post, only: [:show, :destroy]
   #:find_postable

  def index
    @posts = Post.all.order_by(created_at: :desc).limit(50)
  end

  def show
    if !signed_in?
      redirect_to "/users/sign_in"
    end
  end

  def new
    @post = Post.new    
  end
  
  def create
    # When posts need to be polymorphic, uncomment below
    # @postable.attachments.create post_params
    # redirect_to @postable
    @post = Post.new(post_params.to_h)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def post_params
    params.require(:post).permit(:attachment)
  end

  def set_post
    @post = Post.find(params[:id])
  end
  
  # could be improve and include into concerns
  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  # def find_postable
  #   params.each do |name, value|
  #     return @postable = $1.classify.constantize.find(value) if name =~ /(.+)_id$/
  #   end
  # end
end