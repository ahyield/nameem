class SendNotificationDigestJob < ApplicationJob
  queue_as :default

  def perform
    users_with_notifications.find_each do |user|
      notifications = user.notifications.unread.where("created_at > ?", 24.hours.ago).recent.limit(20).to_a
      NotificationMailer.digest(user, notifications).deliver_later
    end
  end

  private

  def users_with_notifications
    User.where(email_notifications: true)
        .joins(:notifications)
        .merge(Notification.unread.where("notifications.created_at > ?", 24.hours.ago))
        .distinct
  end
end
