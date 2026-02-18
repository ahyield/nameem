require "rails_helper"

RSpec.describe MagicLinkMailer do
  describe "#verification_code" do
    let(:magic_link) { create(:magic_link) }
    let(:mail) { described_class.verification_code(magic_link) }

    it "sends to the user's email" do
      expect(mail.to).to eq([magic_link.user.email])
    end

    it "includes the code in the subject" do
      expect(mail.subject).to include(magic_link.code)
    end

    it "includes the code in the body" do
      expect(mail.body.encoded).to include(magic_link.code)
    end
  end
end
