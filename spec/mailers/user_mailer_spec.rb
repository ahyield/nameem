require "rails_helper"

RSpec.describe UserMailer do
  describe "#welcome" do
    let(:user) { create(:user, first_name: "سارة") }

    it "greets the new user and points them at writing and following" do
      writer = create(:user, :picked, first_name: "كاتبة")
      mail = described_class.welcome(user)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("أهلاً بك في نميم، سارة")
      expect(mail.html_part.body.decoded).to include("اكتب موضوعك الأول", writer.name)
      expect(mail["List-Unsubscribe"]).to be_nil
    end
  end
end
