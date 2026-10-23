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
    end

    it "mentions who acted" do
      body = mail.html_part&.body&.decoded || mail.body.decoded
      notifications.each { |notification| expect(body).to include(notification.actor.name) }
    end
  end
end
