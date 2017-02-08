class  Api::V1::LikesController < Api::V1::BaseController
  # skip_before_action :authenticate_user_from_token!

	def like
	  # @current_user = User.find(params[:user_id])
	  @post = Post.find(params[:post_id])
	  like = Like.new(post_id: @post.id.to_s, user_id: @current_user.id.to_s)
	  if like.save
		  like_post_notification(@post, @current_user)
		  render json: {status: 200}
	  else
	  	render json: {error: like.errors}
	  end
	end

	def unlike
	  # @current_user = User.find(params[:user_id])
	  @like = @current_user.likes.find_by_post_id(params[:post_id])
	  @post = Post.find(params[:post_id])
	  @like.destroy!
	end

  def like_post_notification(post, user)
    return if post.user_id.to_s == user.id.to_s
    Notification.create(user_id: post.user_id.to_s,
                        notified_by_id: user.id.to_s,
                        post_id: post.id.to_s,
                        notice_type: 'Liked your post')
  end

end