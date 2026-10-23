# Preview at /rails/mailers in development
class NotificationMailerPreview < ActionMailer::Preview
  def digest
    notifications = Notification.includes(:actor, :notifiable).order(created_at: :desc).limit(5).to_a
    NotificationMailer.digest(notifications.first&.recipient || User.first!, notifications)
  end
end
