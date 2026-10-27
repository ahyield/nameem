require "rails_helper"

RSpec.describe JsonLdHelper do
  let(:author) { create(:user) }

  describe "#article_json_ld" do
    it "describes the article with its cover image" do
      article = create(:article, :published, user: author, title: "عنوان", description: "وصف",
                                             content_html: '<p>نص</p><img src="https://example.com/cover.jpg">')

      data = helper.article_json_ld(article, author)

      expect(data).to include("@type" => "Article", "headline" => "عنوان", "description" => "وصف",
                              "image" => ["https://example.com/cover.jpg"])
      expect(data["author"]).to include("name" => author.name)
    end

    it "leaves out the image and description when there are none" do
      article = create(:article, :published, user: author, description: nil, content_html: nil)

      data = helper.article_json_ld(article, author)
      expect(data).not_to have_key("image")
      expect(data["description"]).to be_nil
    end
  end

  describe "search details" do
    let(:article) do
      create(:article, :published, user: author, title: "رحلة", content_html: "<p>ثلاث كلمات هنا</p>",
                                   tags: [create(:tag, name: "سفر"), create(:tag, name: "مدن")])
    end

    it "points the article at its readable address, with its language, length and topics" do
      data = helper.article_json_ld(article, author)

      expect(data["url"]).to end_with("/#{author.slug}/#{ERB::Util.url_encode('رحلة')}-#{article.short_id}")
      expect(data["mainEntityOfPage"]).to eq("@type" => "WebPage", "@id" => data["url"])
      expect(data).to include("inLanguage" => "ar", "wordCount" => 3, "keywords" => "سفر، مدن", "articleSection" => "سفر")
    end

    it "lays out the breadcrumb from the site to the author to the article" do
      crumbs = helper.article_breadcrumb_json_ld(article, author)["itemListElement"]

      expect(crumbs.pluck("name")).to eq(["نميم", author.name, "رحلة"])
      expect(crumbs.pluck("position")).to eq([1, 2, 3])
    end

    it "describes the site with its search" do
      expect(helper.website_json_ld["potentialAction"]["target"]).to end_with("/search?q={search_term_string}")
    end

    it "describes a topic page" do
      tag = create(:tag, name: "شعر")

      expect(helper.topic_json_ld(tag)).to include("@type" => "CollectionPage", "name" => "شعر")
    end

    it "links an author's other profiles" do
      author.update!(website_url: "https://example.com", twitter_handle: "writer")

      expect(helper.profile_json_ld(author)["sameAs"]).to eq(["https://example.com", "https://x.com/writer"])
    end
  end

  describe "#json_ld_tag" do
    it "can't be broken out of with a closing script tag in a title" do
      html = helper.json_ld_tag("headline" => "</script><script>alert(1)</script>")

      expect(html.scan("</script>").size).to eq(1)
      expect(html).to include("</script>")
    end
  end
end
