require "rails_helper"

RSpec.describe SeoSettings do
  let(:images) { %w[https://example.com/one.jpg https://example.com/two.jpg] }
  let(:article) do
    create(:article, content_html: images.map { |src| %(<figure><img src="#{src}"></figure>) }.join)
  end

  describe "the cover" do
    it "is the image the author chose, or the first one" do
      expect(article.cover_image).to eq(images.first)

      article.update!(cover_image_src: images.last)
      expect(article.cover_image).to eq(images.last)
    end

    it "must be one of the article's images" do
      article.cover_image_src = "https://example.com/elsewhere.jpg"

      expect(article).not_to be_valid
      expect(article.errors[:cover_image_src]).to be_present
    end

    it "stays chosen while the article keeps that image" do
      article.update!(cover_image_src: images.last)
      article.update!(content_html: "<p>نص</p>#{article.content_html}")

      expect(article.cover_image_src).to eq(images.last)
    end

    it "goes back to the first image when the chosen one leaves the article" do
      article.update!(cover_image_src: images.last)
      article.update!(content_html: %(<img src="#{images.first}">))

      expect(article.cover_image_src).to be_nil
      expect(article.cover_image).to eq(images.first)
    end
  end

  describe "the original address" do
    it "is a full https address on another site" do
      article.canonical_url = "https://mynameem.com/post"
      expect(article).to be_valid

      article.canonical_url = "  https://example.com/original  "
      expect(article).to be_valid
      expect(article.canonical_url).to eq("https://example.com/original")

      ["http://example.com/a", "https://nameem.com/someone/else", "https://www.Nameem.com/x", "not a url", "https://"].each do |url|
        article.canonical_url = url
        expect(article).not_to be_valid, url
      end
    end

    it "is optional" do
      article.canonical_url = " "

      expect(article).to be_valid
      expect(article.canonical_url).to be_nil
    end
  end

  it "keeps the search title short" do
    article.seo_title = "ع" * (SeoSettings::SEO_TITLE_LENGTH + 1)

    expect(article).not_to be_valid
  end

  it "only accepts slugs of words joined by dashes" do
    article.slug = "two words"

    expect(article).not_to be_valid
  end

  it "keeps a slug the author chose for a draft as the title changes" do
    article.update!(slug: "اختيار-الكاتب")
    article.update!(title: "عنوان آخر")

    expect(article.slug).to eq("اختيار-الكاتب")
  end
end
