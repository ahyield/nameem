# Preview at /rails/mailers in development
class AnnouncementMailerPreview < ActionMailer::Preview
  def dark_mode
    AnnouncementMailer.dark_mode(User.first!)
  end
end
