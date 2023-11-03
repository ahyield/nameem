class MagicLoginLinkMailer < ApplicationMailer
  def magic_login_link
    @user = params[:user]
    @token = params[:token]

    mail(
      to:      @user.email,
      subject: "Nameem Magic Login Link"
    )
  end
end
