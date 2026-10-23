class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    @writers = User.suggested_for(user, limit: 3)

    mail_user user, category: :account, subject: "أهلاً بك في نميم، #{user.first_name}"
  end
end
