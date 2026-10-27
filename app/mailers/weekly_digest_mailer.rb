class WeeklyDigestMailer < ApplicationMailer
  helper ApplicationHelper, EmailHelper, ArticleLinksHelper

  def best_of(user, digest = WeeklyDigest.current)
    @user = user
    @trending = digest.trending
    @picks = digest.picks
    @writers = User.suggested_for(user, limit: 3)

    mail_user user, category: :weekly, subject: "حصاد الأسبوع على نميم"
  end
end
