class FeedController < ApplicationController
  def index
    @articles = Article.published.order("published_at DESC")
    @users = User.last(6)
  end

  def latest_feed
    @articles = Article.published.order("published_at DESC")
  end

  def picked_feed
    @articles = Article.picked.order("published_at DESC")
  end

  def popular_feed
    @articles = Article.published.order("published_at DESC")
  end
end
