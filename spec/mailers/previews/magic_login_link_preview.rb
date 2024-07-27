# Preview all emails at http://localhost:3000/rails/mailers/magic_login_link
class MagicLoginLinkPreview < ActionMailer::Preview
  def magic_login_link
    user = User.new(name: "أحمد طلبة", email: "tolpa1@gmail.com", confirmed: true)
    MagicLoginLinkMailer.with(user:, token: "").magic_login_link
  end
end
