class CommentsController < ApplicationController
  before_action :set_article

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user
    @reply_to = @comment.parent

    # Collapse reply-to-reply: if parent itself has a parent, move up to grandparent
    if @comment.parent&.parent_id.present?
      @comment.mentioned_user = @comment.parent.user
      @comment.parent_id = @comment.parent.parent_id
    end

    if @comment.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      head :unprocessable_content
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])

    unless @comment.user == current_user || current_user.admin?
      head :forbidden
      return
    end

    @comment.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_article
    user = User.friendly.find(params[:slug])
    @article = user.articles.find_by!(uuid: params[:uuid])
  end

  def comment_params
    params.expect(comment: %i[body parent_id])
  end
end
