class ConfirmEmailMailer < ApplicationMailer
  def confirm_email
    @email = params[:email]
    @token = params[:token]

    mail(
      to:      @email,
      subject: "Nameem Magic Signup Link"
    )
  end
end
