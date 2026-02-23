class UsersController < ApplicationController
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
                                  replies: [:user, :rich_text_body, :comment_likes, :mentioned_user])

    @related_articles = Article.related_to(@article, limit: 3)
                                .includes(:user, :tags, images_attachments: :blob)
    @author_articles = @user.articles.published
                            .where.not(id: @article.id)
                            .order(published_at: :desc)
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

    @articles = @user.articles.published.order(published_at: :desc)
    @total_views = @articles.sum(:real_views_count)
    @total_likes = @articles.sum(:likes_count)
    @total_comments = @articles.sum(:comments_count)
    @profile_views = @user.real_views_count
    @top_article = @articles.order(real_views_count: :desc).first
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
    @article = @user.articles.find_by(uuid: params[:uuid])

    @article.destroy

    redirect_to user_path(@user)
  end
end
