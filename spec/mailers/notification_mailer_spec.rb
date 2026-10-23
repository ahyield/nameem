require "rails_helper"

RSpec.describe NotificationMailer do
  describe "#digest" do
    let(:user) { create(:user) }
    let(:article) { create(:article, :published, user:) }
    let(:notifications) do
      [
        create(:notification, :liked, recipient: user, notifiable: article),
        create(:notification, :commented, recipient: user, notifiable: create(:comment, article:))
      ]
    end
    let(:mail) { described_class.digest(user, notifications) }

    it "goes to the user" do
      expect(mail.to).to eq([user.email])
    end

    it "counts the notifications in the subject" do
      expect(mail.subject).to include("2")
      expect(described_class.digest(user, notifications.first(1)).subject).to eq("لديك إشعار جديد على نميم")
    end

    it "mentions who acted" do
      body = mail.html_part.body.decoded
      notifications.each { |notification| expect(body).to include(notification.actor.name) }
    end

    it "offers one-click unsubscribe from the digest" do
      expect(mail["List-Unsubscribe"].to_s).to include("/email/unsubscribe?token=")
      expect(mail["List-Unsubscribe-Post"].to_s).to eq("List-Unsubscribe=One-Click")
      expect(mail.html_part.body.decoded).to include("إلغاء الاشتراك في هذه الرسائل")
    end

    it "is not delivered once the reader switches the digest off" do
      user.update!(email_notifications: false)
      message = mail

      expect { message.deliver_now }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "shows the postal address when one is configured" do
      allow(Rails.application.credentials).to receive(:dig).and_call_original
      allow(Rails.application.credentials).to receive(:dig).with(:mailer, :postal_address).and_return("ص.ب ١٢٣، القاهرة")

      expect(mail.html_part.body.decoded).to include("ص.ب ١٢٣، القاهرة")
    end
  end
end
