# Preview at /rails/mailers in development; uses existing notifications when there are any
class ActivityMailerPreview < ActionMailer::Preview
  def comment
    notification = Notification.where(action: :commented, notifiable_type: "Comment").last ||
      Notification.new(action: :commented, recipient: User.first!, actor: User.last!, notifiable: Comment.last!)
    ActivityMailer.comment(notification)
  end

  def reply
    notification = Notification.where(action: :replied, notifiable_type: "Comment").last ||
      Notification.new(action: :replied, recipient: User.first!, actor: User.last!, notifiable: Comment.last!)
    ActivityMailer.comment(notification)
  end

  def featured
    article = Article.published.last!
    ActivityMailer.editorial(Notification.new(action: :featured, recipient: article.user, actor: User.first!,
                                              notifiable: article))
  end

  def picked
    article = Article.published.last!
    ActivityMailer.editorial(Notification.new(action: :picked, recipient: article.user, actor: User.first!, notifiable: article))
  end
end
