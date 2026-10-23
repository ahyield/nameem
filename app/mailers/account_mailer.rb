# Security and account-status notices; always sent (category "account")
class AccountMailer < ApplicationMailer
  # Goes to the address being replaced, so the owner hears about a change they didn't make
  def email_changed(user, old_email:)
    @user = user
    @masked_email = mask(user.email)

    mail_user user, category: :account, to: old_email, subject: "تغيّر البريد الإلكتروني لحسابك على نميم"
  end

  def suspended(user)
    @user = user
    mail_user user, category: :account, subject: "تم إيقاف حسابك على نميم مؤقتاً"
  end

  def reinstated(user)
    @user = user
    mail_user user, category: :account, subject: "عاد حسابك على نميم للعمل"
  end

  private

  # reader@example.com -> r*****@example.com
  def mask(email)
    name, domain = email.split("@", 2)
    "#{name.first}#{'*' * [name.length - 1, 3].max}@#{domain}"
  end
end
