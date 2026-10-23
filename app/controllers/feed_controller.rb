class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    # The feed requires signing in, so suggestions always skip what the reader already follows
    @users = User.suggested_for(Current.user)
    @tags = Tag.popular.with_articles.where.not(id: Current.user.following_tags.select(:id)).limit(10)

    @trending = Article.trending(days: 7).limit(5).includes(:user)

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

  def trending_feed
    @pagy, @articles = pagy(Article.trending)

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
        .where.not(user_id: Current.user.id)
        .distinct
        .order(published_at: :desc)
    )

    respond_to do |format|
      format.turbo_stream
    end
  end
end
