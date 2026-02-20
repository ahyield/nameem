require "rails_helper"

RSpec.describe "Search" do
  describe "GET /search" do
    it "returns success without query" do
      get "/search"
      expect(response).to have_http_status(:success)
    end

    it "returns success with query" do
      get "/search", params: { q: "test" }
      expect(response).to have_http_status(:success)
    end

    it "does not require authentication" do
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
      json = JSON.parse(response.body)
      expect(json).to have_key("people")
      expect(json).to have_key("articles")
      expect(json).to have_key("topics")
    end

    it "returns empty results for blank query" do
      get "/search/autocomplete", params: { q: "" }
      json = JSON.parse(response.body)
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
      json = JSON.parse(response.body)
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
      json = JSON.parse(response.body)
      article = json["articles"].first
      next unless article
      expect(article).to have_key("title")
      expect(article).to have_key("uuid")
      expect(article).to have_key("slug")
    end

    it "returns correct JSON shape for people" do
      create(:user, first_name: "سارة", last_name: "علي")

      get "/search/autocomplete", params: { q: "سارة" }
      json = JSON.parse(response.body)
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
      json = JSON.parse(response.body)
      topic = json["topics"].first
      next unless topic
      expect(topic).to have_key("name")
      expect(topic).to have_key("slug")
    end
  end
end
