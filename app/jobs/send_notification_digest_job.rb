class SendNotificationDigestJob < ApplicationJob
  queue_as :default

  # Notifications already sent in an instant email (emailed_at set) aren't repeated in the digest
  def perform
    users_with_notifications.find_each do |user|
      notifications = pending(user.notifications).recent.limit(20).to_a
      NotificationMailer.digest(user, notifications).deliver_later
      Notification.where(id: notifications.map(&:id)).update_all(emailed_at: Time.current)
    end
  end

  private

  def pending(notifications)
    notifications.unread.where(emailed_at: nil).where(created_at: 24.hours.ago..)
  end

  def users_with_notifications
    User.where(email_notifications: true, email_suppressed_at: nil)
        .where(id: pending(Notification.all).select(:recipient_id))
  end
end
