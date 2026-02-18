require "rails_helper"

RSpec.describe Session do
  describe "associations" do
    it "belongs to a user" do
      session = create(:session)
      expect(session.user).to be_a(User)
    end
  end

  describe "creation" do
    it "stores ip_address and user_agent" do
      session = create(:session, ip_address: "192.168.1.1", user_agent: "Mozilla/5.0")
      expect(session.ip_address).to eq("192.168.1.1")
      expect(session.user_agent).to eq("Mozilla/5.0")
    end
  end

  describe "signed_id" do
    it "can be found via find_signed round-trip" do
      session = create(:session)
      token = session.signed_id
      found = described_class.find_signed(token)
      expect(found).to eq(session)
    end

    it "returns nil for tampered tokens" do
      expect(described_class.find_signed("tampered-token")).to be_nil
    end
  end
end
