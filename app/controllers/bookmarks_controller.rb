class BookmarksController < ApplicationController
  before_action :set_article

  def create
    current_user.bookmarks.create(article: @article)
    @bookmarked = true
    @size = params[:size] || "w-6 h-6"

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    current_user.bookmarks.find_by(article: @article)&.destroy
    @bookmarked = false
    @size = params[:size] || "w-6 h-6"

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
