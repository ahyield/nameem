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

    it "is created with normalized email" do
      user = described_class.create(email: "TEST@TEST.com")
      expect(user.email).to eq("test@test.com")
    end

    it "has attached avatar" do
      user = described_class.create(
        email:  "test@test.com",
        avatar: Rack::Test::UploadedFile.new("spec/fixtures/files/avatar.png", "image/png")
      )
      expect(user.avatar).to be_attached
    end

    it "has default avatar as nil" do
      user = described_class.create(email: "test@test.com", avatar: nil)
      expect(user.avatar).not_to be_attached
    end

    it "has many articles" do
      user = described_class.create(email: "test@test.com")
      expect(user.articles).to eq([])

      a1 = user.articles.create(title: "Article 1", content: "Content 1")
      a2 = user.articles.create(title: "Article 2", content: "Content 2")
      expect(user.articles).to include(a1)
      expect(user.articles).to include(a2)
    end

    it "can be featured" do
      user = described_class.create(email: "test@test.com", avatar: nil)
      user.feature

      expect(user.featured).to be_truthy
    end

    it "can be admin" do
      user = described_class.create(email: "test@test.com", avatar: nil)

      user.make_admin

      expect(user).to be_admin
    end

    it "can be editor" do
      user = described_class.create(email: "test@test.com", avatar: nil)

      user.make_editor

      expect(user).to be_editor
    end
  end
end
