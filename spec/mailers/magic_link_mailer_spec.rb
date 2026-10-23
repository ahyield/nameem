require "rails_helper"

RSpec.describe MagicLinkMailer do
  describe "#verification_code" do
    let(:magic_link) { create(:magic_link) }
    let(:mail) { described_class.verification_code(magic_link) }

    it "sends to the user's email from Nameem" do
      expect(mail.to).to eq([magic_link.user.email])
      expect(mail.from).to eq(["noreply@nameem.com"])
      expect(mail[:from].display_names).to eq(["نميم"])
      expect(mail.reply_to).to eq(["support@nameem.com"])
    end

    it "includes the code in the subject and body" do
      expect(mail.subject).to include(magic_link.code)
      expect(mail.html_part.body.decoded).to include(magic_link.code)
    end

    it "words the subject for each purpose" do
      expect(described_class.verification_code(create(:magic_link, :sign_up)).subject).to start_with("تأكيد حسابك")
      expect(described_class.verification_code(create(:magic_link, :confirm_email)).subject).to start_with("تأكيد بريدك الجديد")
    end

    it "reaches unconfirmed and suppressed addresses, without an unsubscribe header" do
      user = create(:user, :unconfirmed, email_suppressed_at: Time.current)

      expect { described_class.verification_code(create(:magic_link, user:)).deliver_now }
        .to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(ActionMailer::Base.deliveries.last["List-Unsubscribe"]).to be_nil
    end

    it "adds a plain-text part and inlines the styles on delivery" do
      delivered = mail.deliver_now

      expect(delivered.text_part.body.decoded).to include(magic_link.code)
      expect(delivered.html_part.body.decoded).to match(/class="code"[^>]*style=/)
    end
  end
end
