class NotificationMailer < ApplicationMailer
  # Arabic counted nouns: إشعار جديد / إشعاران جديدان / 5 إشعارات جديدة / 12 إشعاراً جديداً
  def self.count_phrase(count)
    case count
    when 1 then "إشعار جديد"
    when 2 then "إشعاران جديدان"
    when 3..10 then "#{count} إشعارات جديدة"
    else "#{count} إشعاراً جديداً"
    end
  end

  helper NotificationsHelper, EmailHelper

  def digest(user, notifications)
    @user = user
    @notifications = notifications
    subject = "لديك #{self.class.count_phrase(notifications.size)} على نميم"

    mail_user user, category: :activity_digest, subject:
  end
end
