class MagicLinkMailerPreview < ActionMailer::Preview
  def verification_code
    magic_link = MagicLink.first || FactoryBot.create(:magic_link)
    MagicLinkMailer.verification_code(magic_link)
  end
end
