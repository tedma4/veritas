class Api::V1::PostsController < Api::V1::BaseController
  # skip_before_action :authenticate_user_from_token!
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
    case params[:post_type]
    when "public"
      if @post.save
        render json: {status: 200}
      else
        render json: {errors: @post.errors}
      end
    when "reply"
      if @post.save
        reply_post_notification(@post, params[:user_repling_to], params[:post_replying_to])
        render json: {status: 200}
      else
        render json: {errors: @post.errors}
      end
    when "hidden", "memory"
      if @post.save
        hidden_post_notification(@post) 
        render json: {status: 200}
      else
        render json: {errors: @post.errors}
      end
    else
    end
    ensure
      clean_tempfile
  end
  
  def destroy
    if @post.post_type == "hidden"
      if @post.likes.any?
        like = @post.likes
        if like.count > 1
          like.each do |like|
            like.post_id = "destroyed hidden post"
            like.save(validate: false)
          end
        else
          like.post_id = "destroyed hidden post"
          like.save(validate: false)
        end
      end
    end
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def post_params
    the_params = params.require(:post).permit(:location, :user_id, :post_type, {:selected_users => []}, :attachment, :caption, :user_repling_to, :post_replying_to)
    the_params[:location] = params[:location] if params[:location]
    the_params[:user_id] = @current_user.id if @current_user
    the_params[:post_type] = params[:post_type] if params[:post_type]
    the_params[:selected_users] = params[:selected_users] if params[:selected_users]
    the_params[:caption] = params[:caption] if params[:caption]
    the_params[:user_repling_to] = params[:user_repling_to] if params[:user_repling_to]
    the_params[:post_replying_to] = params[:post_replying_to] if params[:post_replying_to]
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
    return unless ["hidden", "memory"].include?(post.post_type)
    return if post.selected_users.blank?
    users = post.selected_users
    users.each do |user_id|
      Notification.create(user_id: user_id,
                          notified_by_id: post.user_id.to_s,
                          post_id: post.id.to_s,
                          notice_type: post.post_type + " post")
    end
  end

  def reply_post_notification(post, user_id, post_id)
    return if post.post_type != "reply"
    return if post.user_id == user_id
    Notification.create(user_id: user_id,
                        notified_by_id: post.user_id.to_s,
                        post_id: post.id.to_s,
                        identifier: post_id.to_s,
                        notice_type: 'reply post')
  end
end












