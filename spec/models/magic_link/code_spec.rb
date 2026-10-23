require "rails_helper"

RSpec.describe MagicLink::Code do
  describe ".generate" do
    it "returns six characters from the unambiguous alphabet" do
      20.times do
        code = described_class.generate
        expect(code).to match(/\A[0-9ABCDEFGHJKMNPQRSTVWXYZ]{6}\z/)
      end
    end

    it "varies between calls" do
      codes = Array.new(20) { described_class.generate }
      expect(codes.uniq.size).to be > 1
    end
  end

  describe ".sanitize" do
    it "uppercases and maps lookalike letters to digits" do
      expect(described_class.sanitize("abo1il")).to eq("AB0111")
    end
  end
end
