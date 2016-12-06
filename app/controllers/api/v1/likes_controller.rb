class  Api::V1::LikesController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!

	def like
	  @user = User.find(params[:user_id])
	  @post = Post.find(params[:post_id])
	  like = Like.new(post_id: @post.id, user_id: @user.id)
	  if like.save
		  like_post_notification(@post, @user)
		  render json: {status: 200}
	  else
	  	render json: {error: like.errors}
	  end
	end

	def unlike
	  @user = User.find(params[:user_id])
	  @like = @user.likes.find_by_post_id(params[:post_id])
	  @post = Post.find(params[:post_id])
	  @like.destroy!
	end

  def like_post_notification(post, user)
    return if post.user_id == user.id
    Notification.create(user_id: post.user_id,
                        notified_by_id: user.id,
                        post_id: post.id,
                        notice_type: 'liked post')
  end

end