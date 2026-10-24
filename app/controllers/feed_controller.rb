class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    # The feed requires signing in, so suggestions always skip what the reader already follows
    @users = User.suggested_for(Current.user)
    @tags = Tag.popular.with_articles.where.not(id: Current.user.following_tags.select(:id)).limit(10)

    newcomers = Article.newcomers(limit: Trending::Newcomers::SIDEBAR_SLOTS.size)
    @newcomer_ids = newcomers.map(&:id)
    trending = Article.trending.limit(5).includes(:user).to_a
    @trending = Trending::Newcomers.interleave(trending, newcomers, at: Trending::Newcomers::SIDEBAR_SLOTS).first(5)

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

  # Only what's trending (at most Trending::MAX_RANKED) plus the «جديد» slots; it ends there and points
  # readers to الأحدث instead of paging through every article
  def trending_feed
    newcomers = Article.newcomers(limit: Trending::Newcomers::TAB_SLOTS.size)
    @newcomer_ids = newcomers.map(&:id)
    @articles = Trending::Newcomers.interleave(Article.trending.includes(:user).to_a, newcomers,
                                               at: Trending::Newcomers::TAB_SLOTS)

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
