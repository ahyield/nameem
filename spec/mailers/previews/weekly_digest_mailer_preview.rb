# Preview at /rails/mailers in development
class WeeklyDigestMailerPreview < ActionMailer::Preview
  def best_of
    WeeklyDigestMailer.best_of(User.first!)
  end
end
