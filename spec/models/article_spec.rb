require "rails_helper"

RSpec.describe Article do
  context "when article is created" do
    let(:content) { JSON.parse(File.read("spec/fixtures/article.json")) }
    let(:article) { create(:article, title: "New Article", content:) }

    context "with metable" do
      it "has a description" do
        article.update(content: { ops: [{ insert: "Updated Article" }] })
        expect(article.description).to eq("Updated Article\n")
      end

      it "has alternative titles" do
        expect(article.alternative_titles).to eq(["Lorem Ipsum is simply dummy text of the printing and typesetting industry."])
      end

      it "has article images" do
        expect(article.article_images).to eq([])
      end
    end

    it "has a title" do
      expect(article.title).to eq("New Article")
    end

    it "has a body" do
      expect(article.content).to eq(content)
    end

    it "can be published" do
      article.publish
      expect(article.published).to be true
    end

    it "can be unpublished" do
      article.unpublish
      expect(article.published).to be false
    end

    it "has a published date" do
      article = create(:article, title: "New Article", published_at: "2021-01-01")
      expect(article.published_at).to eq("2021-01-01")
    end

    it "has a created date" do
      article = create(:article, title: "New Article", created_at: "2021-01-01")
      expect(article.created_at).to eq("2021-01-01")
    end

    it "has a updated date" do
      article = create(:article, title: "New Article", updated_at: "2021-01-01")
      expect(article.updated_at).to eq("2021-01-01")
    end

    it "has a slug" do
      article = create(:article, title: "New Article", slug: "new-article")
      expect(article.slug).to eq("new-article")
    end

    it "can be picked" do
      article.pick
      expect(article.picked).to be true
    end

    it "can be featured" do
      article.feature
      expect(article.featured).to be true
    end
  end
end
