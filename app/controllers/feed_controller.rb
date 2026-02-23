class FeedController < ApplicationController
  def index
    @pagy, @articles = pagy(Article.published.order(published_at: :desc))
    @users = if Current.user
                followed_ids = Current.user.following_users.pluck(:id) + [Current.user.id]
                User.picked.where.not(id: followed_ids).order("RAND()").limit(4)
              else
                User.picked.order("RAND()").limit(4)
              end
    @tags = if Current.user
               followed_tag_ids = Current.user.following_tags.pluck(:id)
               Tag.popular.with_articles.where.not(id: followed_tag_ids).limit(10)
             else
               Tag.popular.with_articles.limit(10)
             end

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
