class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = User.last(6)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def latest_feed
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def picked_feed
    @pagy, @articles = pagy(Article.picked.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def popular_feed
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
