# Instant emails for comments, replies and editorial picks; see Notification#deliver_instant_email
class ActivityMailer < ApplicationMailer
  helper EmailHelper, ArticleLinksHelper

  def comment(notification)
    @notification = notification
    @comment = notification.notifiable
    @article = @comment.article
    subject = if notification.commented?
                "#{notification.actor.name} علّق على «#{title(@article)}»"
              else
                "#{notification.actor.name} ردّ على تعليقك"
              end

    mail_user notification.recipient, category: :comments, subject:
  end

  def editorial(notification)
    @notification = notification
    @article = notification.notifiable
    subject = notification.featured? ? "مُيِّز موضوعك «#{title(@article)}»" : "اختار المحررون موضوعك «#{title(@article)}»"

    mail_user notification.recipient, category: :editorial, subject:
  end

  private

  def title(article)
    article.title.presence&.truncate(60) || "بدون عنوان"
  end
end
