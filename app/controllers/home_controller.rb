class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @picked = Article.picked.sample(6)
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = User.featured.sample(4)

    respond_to do |format|
      format.html
    end
  end

  def published_articles
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
