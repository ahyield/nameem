require "rails_helper"

RSpec.describe MagicLink do
  describe "code generation" do
    it "auto-generates a 6-character code on create" do
      magic_link = create(:magic_link)
      expect(magic_link.code).to be_present
      expect(magic_link.code.length).to eq(6)
    end

    it "generates codes using base32 characters" do
      magic_link = create(:magic_link)
      expect(magic_link.code).to match(/\A[0-9A-HJKMNP-TV-Z]{6}\z/)
    end
  end

  describe "expiration" do
    it "sets expires_at to 15 minutes from now by default" do
      magic_link = create(:magic_link)
      expect(magic_link.expires_at).to be_within(5.seconds).of(15.minutes.from_now)
    end
  end

  describe "purpose enum" do
    it "supports sign_in purpose" do
      magic_link = create(:magic_link, purpose: :sign_in)
      expect(magic_link).to be_sign_in
    end

    it "supports sign_up purpose" do
      magic_link = create(:magic_link, :sign_up)
      expect(magic_link).to be_sign_up
    end

    it "supports confirm_email purpose" do
      magic_link = create(:magic_link, :confirm_email)
      expect(magic_link).to be_confirm_email
    end
  end

  describe ".consume" do
    it "finds and destroys an active magic link by code" do
      magic_link = create(:magic_link)
      code = magic_link.code

      result = described_class.consume(code)

      expect(result.id).to eq(magic_link.id)
      expect(described_class.find_by(id: magic_link.id)).to be_nil
    end

    it "returns nil for expired codes" do
      magic_link = create(:magic_link, :expired)

      result = described_class.consume(magic_link.code)

      expect(result).to be_nil
      expect(described_class.find_by(id: magic_link.id)).to be_present
    end

    it "returns nil for non-existent codes" do
      result = described_class.consume("ZZZZZZ")
      expect(result).to be_nil
    end

    it "sanitizes the code before lookup" do
      magic_link = create(:magic_link)
      original_code = magic_link.code

      # Replace 0s with Os, 1s with Is (should still match)
      typo_code = original_code.tr("01", "OI")
      result = described_class.consume(typo_code)

      expect(result&.id).to eq(magic_link.id)
    end
  end

  describe "scopes" do
    let!(:active_link) { create(:magic_link) }
    let!(:expired_link) { create(:magic_link, :expired) }

    it ".active excludes expired links" do
      expect(described_class.active).to include(active_link)
      expect(described_class.active).not_to include(expired_link)
    end

    it ".stale returns only expired links" do
      expect(described_class.stale).to include(expired_link)
      expect(described_class.stale).not_to include(active_link)
    end
  end
end
