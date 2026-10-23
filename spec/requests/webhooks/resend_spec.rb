require "rails_helper"

RSpec.describe "Resend webhooks" do
  let(:secret) { "whsec_#{Base64.strict_encode64('test-signing-key')}" }
  let(:user) { create(:user, email: "reader@example.com") }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:resend, :webhook_secret).and_return(secret)
  end

  def deliver(event, timestamp: Time.current.to_i, signature: nil)
    body = event.to_json
    signed = "msg_1.#{timestamp}.#{body}"
    signature ||= Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", "test-signing-key", signed))
    post resend_webhook_path, params: body, headers: {
      "CONTENT_TYPE" => "application/json", "svix-id" => "msg_1", "svix-timestamp" => timestamp.to_s,
      "svix-signature" => "v1,#{signature}"
    }
  end

  it "suppresses an address that hard-bounced" do
    deliver({ type: "email.bounced", data: { to: [user.email], bounce: { type: "Permanent" } } })

    expect(response).to have_http_status(:ok)
    expect(user.reload).to be_email_suppressed
    expect(user.email_suppression_reason).to eq("bounce")
  end

  it "suppresses an address that marked us as spam" do
    deliver({ type: "email.complained", data: { to: [user.email.upcase] } })
    expect(user.reload.email_suppression_reason).to eq("complaint")
  end

  it "accepts events for addresses without an account" do
    deliver({ type: "email.complained", data: { to: ["stranger@example.com"] } })
    expect(response).to have_http_status(:ok)
  end

  it "ignores soft bounces and other events" do
    deliver({ type: "email.bounced", data: { to: [user.email], bounce: { type: "Transient" } } })
    deliver({ type: "email.delivered", data: { to: [user.email] } })

    expect(user.reload).not_to be_email_suppressed
  end

  it "rejects a bad signature, an old timestamp and a missing secret" do
    deliver({ type: "email.complained", data: { to: [user.email] } }, signature: "forged")
    expect(response).to have_http_status(:unauthorized)

    deliver({ type: "email.complained", data: { to: [user.email] } }, timestamp: 10.minutes.ago.to_i)
    expect(response).to have_http_status(:unauthorized)

    allow(Rails.application.credentials).to receive(:dig).with(:resend, :webhook_secret).and_return(nil)
    deliver({ type: "email.complained", data: { to: [user.email] } })
    expect(response).to have_http_status(:unauthorized)
    expect(user.reload).not_to be_email_suppressed
  end

  it "rejects a body that isn't JSON" do
    timestamp = Time.current.to_i
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", "test-signing-key", "msg_1.#{timestamp}.nope"))
    post resend_webhook_path, params: "nope", headers: {
      "CONTENT_TYPE" => "application/json", "svix-id" => "msg_1", "svix-timestamp" => timestamp.to_s,
      "svix-signature" => "v1,#{signature}"
    }

    expect(response).to have_http_status(:bad_request)
  end
end
