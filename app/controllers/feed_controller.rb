class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = User.picked.sample(4)
    @tags = Tag.popular.with_articles.limit(10)

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

  def following_feed
    followed_user_ids = Current.user.following_users.select(:id)
    followed_tag_ids = Current.user.following_tags.select(:id)

    @pagy, @articles = pagy(
      Article.published
        .left_joins(:article_tags)
        .where("articles.user_id IN (?) OR article_tags.tag_id IN (?)", followed_user_ids, followed_tag_ids)
        .distinct
        .order(published_at: :desc)
    )

    respond_to do |format|
      format.turbo_stream
    end
  end
end
