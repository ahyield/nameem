require "rails_helper"

RSpec.describe "Search" do
  describe "GET /search" do
    it "returns success without query" do
      get "/search"
      expect(response).to have_http_status(:success)
    end

    it "returns success with a query, without signing in" do
      get "/search", params: { q: "test" }
      expect(response).to have_http_status(:success)
    end

    it "finds published articles by title" do
      user = create(:user)
      create(:article, :published, title: "مقالة عن البرمجة", user: user)

      get "/search", params: { q: "البرمجة" }
      expect(response.body).to include("مقالة عن البرمجة")
    end

    it "does not find draft articles" do
      user = create(:user)
      create(:article, :draft, title: "مسودة مقالة", user: user)

      get "/search", params: { q: "مسودة" }
      expect(response.body).not_to include("مسودة مقالة")
    end

    it "finds users by name" do
      create(:user, first_name: "أحمد", last_name: "محمد")

      get "/search", params: { q: "أحمد" }
      expect(response.body).to include("أحمد")
    end

    it "finds tags by name" do
      tag = create(:tag, name: "تقنية")
      article = create(:article, :published)
      create(:article_tag, tag: tag, article: article)
      tag.reload

      get "/search", params: { q: "تقنية" }
      expect(response.body).to include("تقنية")
    end

    it "normalizes alef variants in article search" do
      user = create(:user)
      create(:article, :published, title: "إبراهيم يكتب", user: user)

      get "/search", params: { q: "ابراهيم" }
      expect(response.body).to include("إبراهيم يكتب")
    end
  end

  describe "GET /search/autocomplete" do
    it "returns JSON with three categories" do
      get "/search/autocomplete", params: { q: "test" }
      expect(response).to have_http_status(:success)
      json = response.parsed_body
      expect(json).to have_key("people")
      expect(json).to have_key("articles")
      expect(json).to have_key("topics")
    end

    it "returns empty results for blank query" do
      get "/search/autocomplete", params: { q: "" }
      json = response.parsed_body
      expect(json["people"]).to eq([])
      expect(json["articles"]).to eq([])
      expect(json["topics"]).to eq([])
    end

    it "limits results to 3 per category" do
      5.times do |i|
        user = create(:user)
        create(:article, :published, title: "مقالة #{i}", user: user)
      end

      get "/search/autocomplete", params: { q: "مقالة" }
      json = response.parsed_body
      expect(json["articles"].length).to be <= 3
    end

    it "does not require authentication" do
      get "/search/autocomplete", params: { q: "test" }
      expect(response).to have_http_status(:success)
    end

    it "returns correct JSON shape for articles" do
      user = create(:user)
      create(:article, :published, title: "عنوان المقالة", user: user)

      get "/search/autocomplete", params: { q: "عنوان" }
      json = response.parsed_body
      article = json["articles"].first
      next unless article

      expect(article).to have_key("title")
      expect(article).to have_key("uuid")
      expect(article).to have_key("slug")
    end

    it "returns correct JSON shape for people" do
      create(:user, first_name: "سارة", last_name: "علي")

      get "/search/autocomplete", params: { q: "سارة" }
      json = response.parsed_body
      person = json["people"].first
      next unless person

      expect(person).to have_key("name")
      expect(person).to have_key("slug")
      expect(person).to have_key("avatar_url")
    end

    it "returns correct JSON shape for topics" do
      tag = create(:tag, name: "برمجة")
      article = create(:article, :published)
      create(:article_tag, tag: tag, article: article)
      tag.reload

      get "/search/autocomplete", params: { q: "برمجة" }
      json = response.parsed_body
      topic = json["topics"].first
      next unless topic

      expect(topic).to have_key("name")
      expect(topic).to have_key("slug")
    end
  end

  describe "GET /search/autocomplete media" do
    it "includes avatar and cover image URLs when they exist" do
      create(:user, :with_avatar, first_name: "مريم")
      create(:article, :published, title: "مريم والبحر", content_html: '<p>نص</p><img src="/cover.jpg">')

      get "/search/autocomplete", params: { q: "مريم" }

      expect(response.parsed_body["people"].first["avatar_url"]).to start_with("/rails/active_storage/blobs/")
      expect(response.parsed_body["articles"].first["cover_url"]).to eq("/cover.jpg")
    end
  end
end
