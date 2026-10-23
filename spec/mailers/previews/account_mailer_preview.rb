# Preview at /rails/mailers in development; nothing is saved
class AccountMailerPreview < ActionMailer::Preview
  def email_changed
    AccountMailer.email_changed(User.first!, old_email: "old-address@example.com")
  end

  def suspended
    user = User.first!
    user.assign_attributes(suspended_at: Time.current, suspension_reason: "تعليقات مسيئة متكررة")
    AccountMailer.suspended(user)
  end

  def reinstated
    AccountMailer.reinstated(User.first!)
  end
end
