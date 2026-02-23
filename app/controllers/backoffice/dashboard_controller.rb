module Backoffice
  class DashboardController < BaseController
    def index
      @page_title = "الرئيسية"

      @stats = {
        total_users:        User.count,
        confirmed_users:    User.confirmed.count,
        published_articles: Article.published.count,
        draft_articles:     Article.drafts.count,
        total_comments:     Comment.count,
        total_likes:        ArticleLike.count,
        total_tags:         Tag.count,
        total_follows:      Follow.count
      }

      @this_week = {
        new_users:    User.where("created_at >= ?", 1.week.ago).count,
        new_articles: Article.where("created_at >= ?", 1.week.ago).count,
        new_comments: Comment.where("created_at >= ?", 1.week.ago).count,
        new_likes:    ArticleLike.where("created_at >= ?", 1.week.ago).count
      }

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_articles = Article.published.includes(:user).order(published_at: :desc).limit(5)
      @recent_comments = Comment.includes(:user, :article).order(created_at: :desc).limit(5)
      @trending_articles = Article.trending(days: 7).includes(:user).limit(5)
    end
  end
end
