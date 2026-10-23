require "rails_helper"

RSpec.describe AccountMailer do
  let(:user) { create(:user, email: "newname@example.com") }

  it "tells the old address about an email change, masking the new one" do
    mail = described_class.email_changed(user, old_email: "old@example.com")

    expect(mail.to).to eq(["old@example.com"])
    body = mail.html_part.body.decoded
    expect(body).to include("n******@example.com")
    expect(body).not_to include("newname@example.com")
  end

  it "masks short local parts too" do
    user.update!(email: "ab@example.com")
    expect(described_class.email_changed(user, old_email: "x@y.com").html_part.body.decoded).to include("a***@example.com")
  end

  it "explains a suspension with its reason and how to appeal" do
    user.update!(suspended_at: Time.current, suspension_reason: "إساءة متكررة")
    mail = described_class.suspended(user)

    expect(mail.subject).to include("إيقاف")
    expect(mail.html_part.body.decoded).to include("إساءة متكررة", "ردّ على هذه الرسالة")
  end

  it "announces reinstatement" do
    expect(described_class.reinstated(user).subject).to eq("عاد حسابك على نميم للعمل")
  end

  it "reaches suppressed addresses, since these are account notices" do
    user.update!(email_suppressed_at: Time.current)

    expect { described_class.reinstated(user).deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
