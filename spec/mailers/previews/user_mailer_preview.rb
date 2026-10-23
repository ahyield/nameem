# Preview at /rails/mailers in development
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(User.first!)
  end
end
