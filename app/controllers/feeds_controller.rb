# RSS for feed readers and aggregators: the latest articles on Nameem, or by one author
class FeedsController < ApplicationController
  LIMIT = 30

  skip_before_action :require_authentication

  def index
    @articles = Article.published.order(published_at: :desc).includes(:user).limit(LIMIT)
    @title = "نميم"
    @link = root_url
    render_feed
  end

  def author
    @user = User.friendly.find(params[:slug])
    @articles = @user.articles.published.order(published_at: :desc).includes(:user).limit(LIMIT)
    @title = "#{@user.name} — نميم"
    @link = user_url(slug: @user.slug)
    render_feed
  end

  private

  def render_feed
    expires_in 30.minutes, public: true
    render :index, formats: :rss, content_type: "application/rss+xml"
  end
end
