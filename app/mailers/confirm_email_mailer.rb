class ConfirmEmailMailer < ApplicationMailer
  def confirm_email
    @email = params[:email]
    @token = params[:token]

    mail(
      to:      @email,
      subject: "نميم - رابط تأكيد البريد الإلكتروني"
    )
  end
end
