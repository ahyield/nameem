require "rails_helper"

RSpec.describe AnnouncementMailer do
  describe "#dark_mode" do
    let(:user) { create(:user, first_name: "سارة", confirmed: true) }

    it "announces dark mode as «أخبار نميم» with its own unsubscribe" do
      mail = described_class.dark_mode(user)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("نميم صار داكناً، حين تريد")
      expect(mail.html_part.body.decoded).to include("الوضع الداكن وصل أخيراً", "أهلاً سارة", "جرّبه الآن")
      expect(mail["List-Unsubscribe"]).to be_present
    end

    it "isn't delivered to someone who turned the news off" do
      user.update!(email_news: false)

      expect(described_class.dark_mode(user).perform_deliveries).to be(false)
    end
  end
end
