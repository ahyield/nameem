require "rails_helper"

RSpec.describe "Topics" do
  describe "GET /topics" do
    it "returns success" do
      get "/topics"
      expect(response).to have_http_status(:success)
    end

    it "displays tags with articles" do
      tag = create(:tag, name: "tech")
      create(:article_tag, tag: tag, article: create(:article, :published))
      tag.reload

      get "/topics"
      expect(response.body).to include("tech")
    end
  end

  describe "GET /topics/:slug" do
    it "returns success" do
      tag = create(:tag, name: "tech")
      get "/topics/#{tag.slug}"
      expect(response).to have_http_status(:success)
    end

    it "displays the tag name" do
      tag = create(:tag, name: "tech")
      get "/topics/#{tag.slug}"
      expect(response.body).to include("tech")
    end
  end

  describe "GET /topics/:slug/articles" do
    it "returns published articles as turbo stream" do
      tag = create(:tag, name: "tech")
      article = create(:article, :published, title: "Tech Article")
      create(:article_tag, tag: tag, article: article)

      get "/topics/#{tag.slug}/articles", as: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Tech Article")
    end
  end
end
