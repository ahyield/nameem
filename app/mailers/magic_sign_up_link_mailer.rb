class MagicSignUpLinkMailer < ApplicationMailer
  def magic_sign_up_link
    @email = params[:email]
    @token = params[:token]

    mail(
      to:      @email,
      subject: "Nameem Magic Signup Link"
    )
  end
end
