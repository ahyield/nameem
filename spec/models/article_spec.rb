require "rails_helper"

RSpec.describe Article do
  context "when article is created" do
    let(:user) { User.create(email: "test@test.com", slug: "test") }
    let(:content) { { ops: [{ insert: "New Article" }] } }

    context "with metable" do
      it "has a description" do
        article = described_class.create!(title: "New Article", content:, user:)
        article.update(content: { ops: [{ insert: "Updated Article" }] })
        expect(article.description).to eq("Updated Article\n")
      end

      it "has alternative titles" do
        article = described_class.create!(title: "Wow Article", content:, user:)
        expect(article.alternative_titles).to eq(["New Article"])
      end

      it "has article images" do
        article = described_class.create!(title: "New Article", content:, user:)
        expect(article.article_images).to eq([])
      end
    end

    it "has a title" do
      article = described_class.new(title: "New Article")
      expect(article.title).to eq("New Article")
    end

    it "has a body" do
      content = File.read("spec/fixtures/article.json")
      article = described_class.new(content:)

      expect(article.content).to eq(content)
    end

    it "can be published" do
      article = described_class.create!(title: "New Article", content:, user:)

      article.publish
      expect(article.published).to be true
    end

    it "can be unpublished" do
      article = described_class.create!(title: "New Article", content:, published: true, user:)
      article.unpublish
      expect(article.published).to be false
    end

    it "has a published date" do
      article = described_class.new(title: "New Article", content:, published_at: "2021-01-01")
      expect(article.published_at).to eq("2021-01-01")
    end

    it "has a created date" do
      article = described_class.new(title: "New Article", content:, created_at: "2021-01-01")
      expect(article.created_at).to eq("2021-01-01")
    end

    it "has a updated date" do
      article = described_class.new(title: "New Article", content:, updated_at: "2021-01-01")
      expect(article.updated_at).to eq("2021-01-01")
    end

    it "has a user" do
      article = described_class.new(title: "New Article", content:, user:)
      expect(article.user).to eq(user)
    end

    it "has a slug" do
      article = described_class.new(title: "New Article", content:, slug: "new-article")
      expect(article.slug).to eq("new-article")
    end

    it "has a uuid" do
      article = described_class.new(title: "New Article", content:, uuid: "123e4567-e89b-12d3-a456-426614174000")
      expect(article.uuid).to eq("123e4567-e89b-12d3-a456-426614174000")
    end

    it "can be picked" do
      article = described_class.create!(title: "New Article", content:, user:)
      article.pick
      expect(article.picked).to be true
    end

    it "can be featured" do
      article = described_class.create!(title: "New Article", content:, user:)
      article.feature
      expect(article.featured).to be true
    end
  end
end
