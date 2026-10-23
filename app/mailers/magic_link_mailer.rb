class MagicLinkMailer < ApplicationMailer
  COPY = {
    "sign_in"       => {
      subject: "رمز الدخول إلى نميم", heading: "رمز الدخول", intro: "استخدم هذا الرمز لتسجيل الدخول إلى نميم:"
    },
    "sign_up"       => {
      subject: "تأكيد حسابك على نميم", heading: "أهلاً بك في نميم", intro: "استخدم هذا الرمز لتأكيد حسابك الجديد:"
    },
    "confirm_email" => {
      subject: "تأكيد بريدك الجديد", heading: "تأكيد بريدك الجديد", intro: "استخدم هذا الرمز لتأكيد عنوان بريدك الجديد:"
    }
  }.freeze

  def verification_code(magic_link)
    @magic_link = magic_link
    @copy = COPY.fetch(magic_link.purpose, COPY["sign_in"])

    mail_user magic_link.user, category: :account, subject: "#{@copy[:subject]}: #{magic_link.code}"
  end
end
