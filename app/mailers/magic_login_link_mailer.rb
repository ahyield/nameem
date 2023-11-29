class MagicLoginLinkMailer < ApplicationMailer
  def magic_login_link
    @user = params[:user]
    @token = params[:token]

    mail(
      to:      @user.email,
      subject: "نمين - رابط تسيجل الدخول"
    )
  end
end
