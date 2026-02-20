class NotificationMailer < ApplicationMailer
  def digest(user, notifications)
    @user = user
    @notifications = notifications
    mail to: @user.email, subject: "نميم - لديك #{@notifications.size} إشعارات جديدة"
  end
end
