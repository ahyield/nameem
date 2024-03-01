require "rails_helper"

RSpec.describe Article do
  context "when article is created" do
    let(:user) { User.create(email: "test@test.com", slug: "test") }

    it "has a title" do
      article = described_class.new(title: "New Article")
      expect(article.title).to eq("New Article")
    end

    it "has a body" do
      content = File.read("spec/fixtures/article.json")
      article = described_class.new(content: content)

      expect(article.content).to eq(content)
    end

    it "can be published" do
      article = described_class.create!(title: "New Article", content: "Article Content", user: user)

      article.publish
      expect(article.published).to be true
    end

    it "can be unpublished" do
      article = described_class.create!(title: "New Article", content: "Article Content", published: true, user: user)
      article.unpublish
      expect(article.published).to be false
    end

    it "has a published date" do
      article = described_class.new(title: "New Article", content: "Article Content", published_at: "2021-01-01")
      expect(article.published_at).to eq("2021-01-01")
    end

    it "has a created date" do
      article = described_class.new(title: "New Article", content: "Article Content", created_at: "2021-01-01")
      expect(article.created_at).to eq("2021-01-01")
    end

    it "has a updated date" do
      article = described_class.new(title: "New Article", content: "Article Content", updated_at: "2021-01-01")
      expect(article.updated_at).to eq("2021-01-01")
    end
  end
end
