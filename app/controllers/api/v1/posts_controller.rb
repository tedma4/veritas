class Api::V1::PostsController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!
  before_action :set_post, only: [:show, :destroy]

  def index
    @posts = Post.all.order_by(id: :desc)
  end

  def show    
  end

  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params.to_h)
    if @post.post_type == "none"
      @post.save
    else
      # binding.pry
      # @post.selected_users = params[:selected_users]
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
    # binding.pry
    the_params = params.require(:post).permit(:location, :user_id, :post_type, :selected_users, :attachment)
    # the_params[:location] = the_params[:location]
    # the_params[:user_id] = the_params[:user_id]
    # the_params[:post_type] = the_params[:post_type]
    # binding.pry
    the_params[:selected_users] = the_params[:selected_users].split(",") if the_params[:selected_users]
    the_params[:attachment] = parse_post_data(the_params[:attachment]) if the_params[:attachment]
    the_params.delete_if {|k, v| v == nil}
    return the_params
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

  def hidden_post_notification(post)
    return if post.post_type != "hidden"
    return unless post.selected_users
    users = post.selected_users
    users.each do |user_id|
      Notification.create(user_id: user_id,
                          notified_by_id: post.user_id,
                          post_id: post.id,
                          notice_type: 'hidden post')
    end
  end
end












