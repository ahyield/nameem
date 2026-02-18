class MagicLinkMailer < ApplicationMailer
  def verification_code(magic_link)
    @magic_link = magic_link
    @user = magic_link.user

    mail to: @user.email, subject: "نميم - رمز التحقق: #{@magic_link.code}"
  end
end
