require "rails_helper"

RSpec.describe User do
  context "when user is created" do
    it "is invalid with invalid email" do
      expect(described_class.new(email: "")).not_to be_valid
      expect(described_class.new(email: "test")).not_to be_valid
      expect(described_class.new(email: "test@")).not_to be_valid
      expect(described_class.new(email: "test@test.")).not_to be_valid
    end

    it "is valid with valid email" do
      expect(described_class.new(email: "test@test.com")).to be_valid
      expect(described_class.new(email: "TEST@TEST.com")).to be_valid
    end

    it "is invalid with invalid slug" do
      expect(described_class.new(email: "test@test.com", slug: "")).not_to be_valid
      expect(described_class.new(email: "test@test.com", slug: "backoffice")).not_to be_valid
    end

    it "is valid with valid slug" do
      expect(described_class.new(email: "test@test.com", slug: "test")).to be_valid
      expect(described_class.new(email: "test@test.com", slug: "test-1")).to be_valid
      expect(described_class.new(email: "test@test.com", slug: "test_1")).to be_valid
    end

    it "is created with default slug" do
      user = described_class.create(email: "test@test.com")
      expect(user.slug).to eq("test-test-com")
    end

    it "is created with custom slug" do
      user = described_class.create(email: "test@test.com", slug: "test")
      expect(user.slug).to eq("test")
    end
  end
end
