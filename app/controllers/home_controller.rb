class HomeController < ApplicationController
  skip_before_action :require_authentication
  before_action :resume_session

  def index
    @picked = Article.picked.order(published_at: :desc).limit(6)
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = User.featured.order("RAND()").limit(20)
    @tags = Tag.popular.with_articles.limit(4).includes(:articles)

    respond_to do |format|
      format.html
    end
  end

  def published_articles
    @pagy, @articles = pagy(Article.most_popular)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
