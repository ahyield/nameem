class CommentLikesController < ApplicationController
  before_action :refuse_suspended_user, only: :create
  before_action :set_comment

  def create
    if @comment.user == current_user
      head :unprocessable_content
      return
    end

    current_user.comment_likes.create(comment: @comment)
    @comment.reload
    @liked = true

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    current_user.comment_likes.find_by(comment: @comment)&.destroy
    @comment.reload
    @liked = false

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_comment
    user = User.friendly.find(params[:slug])
    @article = user.articles.find_by!(uuid: params[:uuid])
    @comment = @article.comments.find(params[:id])
  end
end
