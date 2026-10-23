# Preview at /rails/mailers in development; builds unsaved records from existing data
class MagicLinkMailerPreview < ActionMailer::Preview
  def sign_in
    code_for(:sign_in)
  end

  def sign_up
    code_for(:sign_up)
  end

  def confirm_email
    code_for(:confirm_email)
  end

  private

  def code_for(purpose)
    MagicLinkMailer.verification_code(MagicLink.new(user: User.first!, code: "AB12CD", purpose:))
  end
end
