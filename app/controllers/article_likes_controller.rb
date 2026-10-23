class ArticleLikesController < ApplicationController
  before_action :set_article

  def create
    if @article.user == current_user
      head :unprocessable_content
      return
    end

    current_user.article_likes.create(article: @article)
    @article.reload
    @liked = true

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    current_user.article_likes.find_by(article: @article)&.destroy
    @article.reload
    @liked = false

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_article
    user = User.friendly.find(params[:slug])
    @article = user.articles.find_by!(uuid: params[:uuid])
  end
end
