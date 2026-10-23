module Backoffice
  class DashboardController < BaseController
    def index
      @page_title = "الرئيسية"

      week_ago = 1.week.ago
      @stats = [
        { label: "المقالات المنشورة", value: Article.published.count, week: Article.where(created_at: week_ago..).count },
        { label: "المستخدمين", value: User.count, week: User.where(created_at: week_ago..).count },
        { label: "التعليقات", value: Comment.count, week: Comment.where(created_at: week_ago..).count },
        { label: "الإعجابات", value: ArticleLike.count, week: ArticleLike.where(created_at: week_ago..).count },
        { label: "المواضيع", value: Tag.count, week: nil },
        { label: "بلاغات معلقة", value: Report.pending.count, week: nil }
      ]

      @activity = recent_activity.first(12)
      @trending_articles = Article.trending(days: 7).includes(:user).limit(5)
    end

    private

    def recent_activity
      users = User.with_attached_avatar.order(created_at: :desc).limit(5)
      articles = Article.published.includes(user: { avatar_attachment: :blob }).order(published_at: :desc).limit(5)
      comments = Comment.with_rich_text_body.includes(user: { avatar_attachment: :blob }).order(created_at: :desc).limit(5)

      activity = users.map { |u| { type: :user, record: u, time: u.created_at } }
      activity += articles.map { |a| { type: :article, record: a, time: a.published_at || a.created_at } }
      activity += comments.map { |c| { type: :comment, record: c, time: c.created_at } }
      activity.sort_by { |item| -item[:time].to_i }
    end
  end
end
