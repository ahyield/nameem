require "rails_helper"

RSpec.describe Permalinkable do
  describe ".slug_from" do
    it "keeps Arabic words, without their short vowels, joined by dashes" do
      expect(Article.slug_from("رحلةٌ إلى نيو-يورك!")).to eq("رحلة-إلى-نيو-يورك")
    end

    it "lowercases Latin words and drops punctuation" do
      expect(Article.slug_from("Hello, World — مرحباً")).to eq("hello-world-مرحبا")
    end

    it "has nothing to offer for a title of only punctuation" do
      expect(Article.slug_from("...")).to be_nil
    end

    it "shortens a long title at a word" do
      slug = Article.slug_from("كلمة " * 30)

      expect(slug.length).to be <= Permalinkable::SLUG_LENGTH
      expect(slug).to end_with("كلمة")
    end

    it "cuts a single very long word where it must" do
      expect(Article.slug_from("a" * 80).length).to eq(Permalinkable::SLUG_LENGTH)
    end
  end

  describe "the slug" do
    it "follows the title while the article is a draft" do
      article = create(:article, title: "الأولى")
      article.update!(title: "الثانية")

      expect(article.slug).to eq("الثانية")
    end

    it "stays put once the article is published" do
      article = create(:article, title: "الأولى")
      article.update!(published: true)
      article.update!(title: "الثانية")

      expect(article.slug).to eq("الأولى")
    end

    it "comes from the opening text when there's no title" do
      article = create(:article, title: nil, content_html: "<p>مطلع المقال هنا</p>")

      expect(article.slug).to eq("مطلع-المقال-هنا")
    end
  end

  describe "#permalink_param" do
    it "is the slug and the start of the UUID" do
      article = create(:article, title: "رحلة", uuid: "01bc2c65-48ea-4f43-86e9-7a7574df4c7f")

      expect(article.permalink_param).to eq("رحلة-01bc2c65")
    end

    it "is just the short id when there are no words to use" do
      article = create(:article, title: nil, content_html: nil, uuid: "01bc2c65-48ea-4f43-86e9-7a7574df4c7f")

      expect(article.permalink_param).to eq("01bc2c65")
    end

    it "uses the title for articles saved before slugs existed" do
      article = create(:article, :published, title: "قديم")
      article.update_column(:slug, nil)

      expect(article.permalink_param).to eq("قديم-#{article.short_id}")
    end
  end

  describe ".at_link" do
    let!(:article) { create(:article, title: "رحلة", uuid: "01bc2c65-48ea-4f43-86e9-7a7574df4c7f") }

    it "finds an article by its permalink, its short id or its UUID" do
      expect(Article.at_link("رحلة-01bc2c65")).to eq(article)
      expect(Article.at_link("كلمات-قديمة-01bc2c65")).to eq(article)
      expect(Article.at_link("01bc2c65-48ea-4f43-86e9-7a7574df4c7f")).to eq(article)
    end

    it "prefers the article whose slug matches when two share a short id" do
      twin = create(:article, title: "توأم", uuid: "01bc2c65-0000-4000-8000-000000000000")

      expect(Article.at_link("توأم-01bc2c65")).to eq(twin)
    end

    it "finds nothing for an unknown or malformed address" do
      expect(Article.at_link("رحلة-deadbeef")).to be_nil
      expect(Article.at_link("no-id-here")).to be_nil
    end
  end
end
