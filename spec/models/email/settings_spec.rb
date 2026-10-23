require "rails_helper"

RSpec.describe Email::Settings do
  around do |example|
    keys = %w[RESEND_API_KEY RESEND_WEBHOOK_SECRET MAILER_POSTAL_ADDRESS]
    saved = ENV.to_h.slice(*keys)
    example.run
  ensure
    keys.each { |key| ENV.delete(key) }
    ENV.update(saved)
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:resend, :api_key).and_return("re_from_credentials")
    allow(Rails.application.credentials).to receive(:dig).with(:resend, :webhook_secret).and_return("whsec_credentials")
    allow(Rails.application.credentials).to receive(:dig).with(:mailer, :postal_address).and_return("عنوان من الإعدادات")
  end

  it "prefers environment variables" do
    ENV.update("RESEND_API_KEY" => "re_from_env", "RESEND_WEBHOOK_SECRET" => "whsec_env", "MAILER_POSTAL_ADDRESS" => "عنوان")

    expect(described_class.resend_api_key).to eq("re_from_env")
    expect(described_class.resend_webhook_secret).to eq("whsec_env")
    expect(described_class.postal_address).to eq("عنوان")
  end

  it "falls back to credentials when a variable is empty or missing" do
    ENV["RESEND_WEBHOOK_SECRET"] = ""
    ENV.delete("RESEND_API_KEY")
    ENV.delete("MAILER_POSTAL_ADDRESS")

    expect(described_class.resend_api_key).to eq("re_from_credentials")
    expect(described_class.resend_webhook_secret).to eq("whsec_credentials")
    expect(described_class.postal_address).to eq("عنوان من الإعدادات")
  end
end
