# One-off product news ("أخبار نميم"), sent by the announcements rake tasks
class AnnouncementMailer < ApplicationMailer
  def dark_mode(user)
    @user = user

    mail_user user, category: :news, subject: "نميم صار داكناً، حين تريد"
  end
end
