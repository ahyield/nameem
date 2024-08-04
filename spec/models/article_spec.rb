require "rails_helper"

RSpec.describe Article do
  let(:content) { JSON.parse(File.read("spec/fixtures/article.json")) }
  let(:article) { create(:article, title: "New Article", content:) }

  describe "attributes" do
    it "has a title" do
      expect(article.title).to eq("New Article")
    end

    it "has a body" do
      expect(article.content).to eq(content)
    end

    it "has a published date" do
      article = create(:article, title: "New Article", published_at: "2021-01-01")
      expect(article.published_at).to eq(Date.parse("2021-01-01"))
    end

    it "has a created date" do
      article = create(:article, title: "New Article", created_at: "2021-01-01")
      expect(article.created_at).to eq(Date.parse("2021-01-01"))
    end

    it "has an updated date" do
      article = create(:article, title: "New Article", updated_at: "2021-01-01")
      expect(article.updated_at).to eq(Date.parse("2021-01-01"))
    end

    it "has a slug" do
      article = create(:article, title: "New Article", slug: "new-article")
      expect(article.slug).to eq("new-article")
    end
  end

  describe "metable" do
    context "when updating content" do
      let(:content_text) { "Lorem Ipsum is simply dummy text of the printing and typesetting industry." }
      let(:content) { { ops: [{ insert: content_text }] } }

      before do
        article.update(content: { ops: [{ insert: "Updated Article" }] })
      end

      it "has a description" do
        expect(article.description).to eq("Updated Article\n")
      end

      it "has alternative titles" do
        article = create(:article, title: nil, user: create(:user), content:)
        expect(article.alternative_titles).to eq(["Lorem Ipsum is simply dummy text of the printing and typesetting industry."])
      end

      it "has article images" do
        expect(article.article_images).to eq([])
      end
    end
  end

  describe "publishing" do
    it "can be published" do
      article.publish
      expect(article.published).to be true
    end

    it "can be unpublished" do
      article.unpublish
      expect(article.published).to be false
    end
  end

  describe "features" do
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
