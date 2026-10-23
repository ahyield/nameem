# Preview at /rails/mailers in development; uses existing notifications, or unsaved samples when there are none
class ActivityMailerPreview < ActionMailer::Preview
  def comment
    ActivityMailer.comment(comment_notification(:commented))
  end

  def reply
    ActivityMailer.comment(comment_notification(:replied))
  end

  def featured
    ActivityMailer.editorial(article_notification(:featured))
  end

  def picked
    ActivityMailer.editorial(article_notification(:picked))
  end

  private

  def comment_notification(action)
    Notification.where(action:, notifiable_type: "Comment").last ||
      Notification.new(action:, recipient: User.first!, actor: User.last!, notifiable: sample_comment)
  end

  def article_notification(action)
    article = Article.published.last!
    Notification.new(action:, recipient: article.user, actor: User.first!, notifiable: article)
  end

  def sample_comment
    Comment.last || Comment.new(article: Article.published.last!, user: User.last!,
                                body: "قرأت موضوعك مرتين. الفقرة الأخيرة تحديداً بقيت معي طوال اليوم، شكراً لك.")
  end
end
