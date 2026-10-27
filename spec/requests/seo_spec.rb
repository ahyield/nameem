require "rails_helper"

RSpec.describe "Search engines" do
  let(:author) { create(:user) }
  let(:tag) { create(:tag, name: "سفر") }
  let!(:article) do
    create(:article, :published, user: author, title: "رحلة إلى المدينة", description: "عن الرحلة", tags: [tag],
                                 content_html: "<p>نص</p>")
  end
  let(:permalink) { "/#{author.slug}/#{ERB::Util.url_encode(article.permalink_param)}" }

  def head_tag(selector)
    response.parsed_body.at_css(selector)
  end

  describe "article addresses" do
    it "shows the article at its readable address" do
      get permalink

      expect(response).to have_http_status(:ok)
      expect(head_tag("link[rel=canonical]")["href"]).to eq("http://www.example.com#{permalink}")
    end

    it "moves old UUID links and changed slugs to the readable address" do
      get "/#{author.slug}/#{article.uuid}"
      expect(response).to redirect_to("http://www.example.com#{permalink}")
      expect(response).to have_http_status(:moved_permanently)

      get "/#{author.slug}/old-words-#{article.short_id}"
      expect(response).to redirect_to("http://www.example.com#{permalink}")
    end

    it "answers not found for an address that isn't an article" do
      get "/#{author.slug}/00000000-0000-0000-0000-000000000000"
      expect(response).to have_http_status(:not_found)

      get "/#{author.slug}/words-deadbeef"
      expect(response).to have_http_status(:not_found)
    end

    it "keeps search engines away from a draft its author is previewing" do
      draft = create(:article, user: author, published_at: nil)
      sign_in(author)

      get "/#{author.slug}/#{draft.uuid}"

      expect(response).to have_http_status(:ok)
      expect(head_tag("meta[name=robots]")["content"]).to eq("noindex, follow")
    end
  end

  describe "the article's head" do
    it "describes it for link previews, with its topics" do
      get "#{permalink}?utm_source=x"
      page = response.parsed_body

      expect(page.at_css("link[rel=canonical]")["href"]).not_to include("utm_source")
      expect(page.at_css("meta[property='og:title']")["content"]).to eq("رحلة إلى المدينة")
      expect(page.at_css("meta[name='twitter:description']")["content"]).to eq("عن الرحلة")
      expect(page.at_css("meta[property='article:tag']")["content"]).to eq("سفر")
      expect(page.at_css("meta[property='og:image']")["content"]).to include("og-default")
      expect(page.css("script[type='application/ld+json']").map { |script| JSON.parse(script.text)["@type"] })
        .to include("Article", "BreadcrumbList")
    end

    it "shares the cover cropped to the size link previews use" do
      blob = ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                                                    filename: "cover.jpeg", content_type: "image/jpeg")
      article.update!(content_html: %(<p>نص</p><img src="/rails/active_storage/blobs/proxy/#{blob.signed_id}/cover.jpeg">))

      get permalink

      expect(head_tag("meta[property='og:image']")["content"]).to include("/rails/active_storage/representations/")
      expect(head_tag("meta[property='og:image:width']")["content"]).to eq("1200")
    end
  end

  it "keeps the page number but no other query in a list's canonical address" do
    get "/topics?page=2&utm_source=x"

    expect(head_tag("link[rel=canonical]")["href"]).to eq("http://www.example.com/topics?page=2")
  end

  it "keeps search results out of search engines" do
    get "/search", params: { q: "رحلة" }

    expect(head_tag("meta[name=robots]")["content"]).to eq("noindex, follow")
  end

  describe "the sitemap" do
    it "lists published articles at their readable address, their authors and topics, but not drafts" do
      draft = create(:article, user: author, title: "مسودة")

      get "/sitemap.xml"

      expect(response.media_type).to eq("application/xml")
      expect(response.body).to include("http://www.example.com#{permalink}", "/#{author.slug}</loc>", "/topics/")
      expect(response.body).not_to include(draft.short_id)
    end
  end

  describe "RSS" do
    it "carries the latest articles" do
      get "/rss"

      expect(response.media_type).to eq("application/rss+xml")
      expect(response.body).to include("<title>رحلة إلى المدينة</title>", "http://www.example.com#{permalink}")
    end

    it "carries one author's articles" do
      other = create(:article, :published, title: "لكاتب آخر")

      get "/#{author.slug}/rss"

      expect(response.body).to include("رحلة إلى المدينة")
      expect(response.body).not_to include(other.title)
    end
  end
end
