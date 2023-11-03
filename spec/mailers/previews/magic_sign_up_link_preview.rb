# Preview all emails at http://localhost:3000/rails/mailers/magic_sign_up_link
class MagicSignUpLinkPreview < ActionMailer::Preview
  def magic_sign_up_link
    MagicSignUpLinkMailer.with(email: "", token: "").magic_sign_up_link
  end
end
