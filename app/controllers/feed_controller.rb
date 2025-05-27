class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = User.picked.sample(4)

    respond_to do |format|
      format.html
    end
  end

  def latest_feed
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))

    respond_to do |format|
      format.turbo_stream
    end
  end

  def picked_feed
    @pagy, @articles = pagy(Article.picked.order(published_at: :desc))

    respond_to do |format|
      format.turbo_stream
    end
  end

  def popular_feed
    @pagy, @articles = pagy(Article.most_popular)

    respond_to do |format|
      format.turbo_stream
    end
  end
end
