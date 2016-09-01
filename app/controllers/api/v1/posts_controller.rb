class Api::V1::PostsController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
  before_action :set_post, only: [:show, :destroy]
   #:find_postable

  def index
    @posts = Post.all.order_by(id: :desc)
  end

  def show    
  end

  def new
    @post = Post.new    
  end
  
  def create
    # When posts need to be polymorphic, uncomment below
    # @postable.attachments.create post_params
    # redirect_to @postable
    binding.pry
    @post = Post.new(post_params)
    if @post.hidden == false
      @post.save
    else
      @post.selected_users = params[:selected_users]
      @post.save
      hidden_post_notification @post
    end
    ensure
      clean_tempfile
  end
  
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def post_params
    the_params = params.require(:post).permit(:location, :user_id, :hidden, :selected_users, :attachment)
    the_params[:location] = params[:location]
    the_params[:user_id] = params[:user_id]
    the_params[:hidden] = params[:hidden]
    the_params[:selected_users] = params[:selected_users]
    the_params[:attachment] = parse_post_data(the_params[:attachment]) if the_params[:attachment]
    the_params.to_h
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def parse_post_data(base64_post)
    filename = "upload-post"
    # in_content_type, encoding, string = base64_post.split(/[:;,]/)[0..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(base64_post)
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
  
  # could be improve and include into concerns
  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  # def find_postable
  #   params.each do |name, value|
  #     return @postable = $1.classify.constantize.find(value) if name =~ /(.+)_id$/
  #   end
  # end

  def hidden_post_notification(post)
    return if post.user.id == current_user.id
    users = post.selected_users.split(',')
    users.each do |user_id|
      Notification.create(user_id: user_id,
                          notified_by_id: current_user.id,
                          post_id: post.id,
                          notice_type: 'hidden post')
    end
  end
end












