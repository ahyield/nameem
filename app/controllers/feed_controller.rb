class FeedController < ApplicationController
  def index
    @articles = Article.published.order("published_at DESC")
    @users = User.last(6)
  end
end
