class UsersController < ApplicationController
  STATS_SORTS = {
    "date"     => :published_at,
    "views"    => :real_views_count,
    "likes"    => :likes_count,
    "comments" => :comments_count
  }.freeze

  skip_before_action :require_authentication, only: %i[show articles article followers following]
  before_action :resume_session, only: %i[show articles article followers following]

  def show
    @user = User.friendly.find(params[:slug])
  end

  def article
    @user = User.friendly.find(params[:slug])
    @article = @user.articles.find_by(uuid: params[:uuid])

    authorize @article, :show?

    @liked = Current.user&.article_likes&.exists?(article: @article)
    @bookmarked = Current.user&.bookmarks&.exists?(article: @article)
    @comments = @article.comments.top_level.newest_first
                        .includes(:user, :rich_text_body, :comment_likes, :mentioned_user,
                                  replies: %i[user rich_text_body comment_likes mentioned_user])

    @related_articles = RelatedArticles.for(@article, limit: 3)
    # The author's articles readers engaged with most, rather than just the latest
    @author_articles = @user.articles.published.where.not(id: @article.id)
                            .includes(images_attachments: :blob)
                            .order(Arel.sql("likes_count * 3 + comments_count * 5 + real_views_count DESC, published_at DESC"))
                            .limit(3)
                            .includes(:tags, images_attachments: :blob)

    if policy(@article).edit?
      @likers = @article.article_likes
                        .includes(user: { avatar_attachment: :blob })
                        .order(created_at: :desc)
                        .map(&:user)
      @commenters = User.where(id: @article.comments.select(:user_id))
                        .includes(avatar_attachment: :blob)
    end

    respond_to do |format|
      format.html
      format.json { render json: @article }
    end
  end

  def articles
    @user = User.friendly.find(params[:slug])
    @pagy, @articles = pagy(@user.articles.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def drafts
    @user = User.friendly.find(params[:slug])
    @pagy, @articles = pagy(@user.articles.drafts.order(updated_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def stats
    @user = User.friendly.find(params[:slug])
    authorize @user, :stats?

    articles = @user.articles.published
    article_ids = articles.ids

    @sort = STATS_SORTS.key?(params[:sort]) ? params[:sort] : "date"
    @direction = params[:direction] == "asc" ? :asc : :desc
    @articles = articles.reorder(STATS_SORTS[@sort] => @direction, :id => :desc)

    @total_views = articles.sum(:real_views_count)
    @total_likes = articles.sum(:likes_count)
    @total_comments = articles.sum(:comments_count)
    @profile_views = @user.real_views_count
    @max_views = articles.maximum(:real_views_count).to_i
    @top_article = articles.where(real_views_count: @max_views).reorder(published_at: :desc).first if @max_views.positive?

    week_ago = 1.week.ago
    @this_week = {
      views:    PageView.where(viewable_type: "Article", viewable_id: article_ids).where(created_at: week_ago..).count,
      profile:  PageView.where(viewable: @user).where(created_at: week_ago..).count,
      likes:    ArticleLike.where(article_id: article_ids).where(created_at: week_ago..).count,
      comments: Comment.where(article_id: article_ids).where(created_at: week_ago..).count
    }

    @daily_readers = daily_readers(article_ids, days: 30)
  end

  def bookmarks
    @user = User.friendly.find(params[:slug])
    authorize @user, :bookmarks?

    @pagy, @articles = pagy(
      @user.bookmarked_articles.published.order("bookmarks.created_at DESC")
    )
  end

  def followers
    @user = User.friendly.find(params[:slug])
    @pagy, @followers = pagy(@user.followers)
  end

  def following
    @user = User.friendly.find(params[:slug])
    @following_users = @user.following_users
    @following_tags = @user.following_tags
  end

  def destroy
    @user = User.friendly.find(params[:slug])
    @article = @user.articles.find_by!(uuid: params[:uuid])
    authorize @article, :destroy?

    @article.destroy

    redirect_to user_path(@user)
  end

  private

  # New unique readers per day (a page view is recorded once per visitor), oldest first
  def daily_readers(article_ids, days:)
    start = (days - 1).days.ago.to_date
    counts = PageView.where(viewable_type: "Article", viewable_id: article_ids)
                     .where(created_at: start.beginning_of_day..)
                     .group("DATE(created_at)")
                     .count
                     .transform_keys(&:to_date)

    (start..Date.current).map { |date| [date, counts.fetch(date, 0)] }
  end
end
