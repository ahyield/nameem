class NotificationMailer < ApplicationMailer
  helper NotificationsHelper

  def digest(user, notifications)
    @user = user
    @notifications = notifications
    count = notifications.size
    subject = count == 1 ? "لديك إشعار جديد على نميم" : "لديك #{count} إشعارات جديدة على نميم"

    mail_user user, category: :activity_digest, subject:
  end
end
