require "rails_helper"

RSpec.describe "Backoffice::Articles", type: :request do
  let(:editor) { create(:editor) }
  let(:user) { create(:user) }
  let!(:article) { create(:article, :published, user: user) }

  before { authenticate_user(editor) }

  describe "GET /backoffice/articles" do
    it "returns success" do
      get backoffice_articles_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by published" do
      get backoffice_articles_path(filter: "published")
      expect(response).to have_http_status(:ok)
    end

    it "filters by drafts" do
      get backoffice_articles_path(filter: "drafts")
      expect(response).to have_http_status(:ok)
    end

    it "filters by featured" do
      get backoffice_articles_path(filter: "featured")
      expect(response).to have_http_status(:ok)
    end

    it "searches by title" do
      get backoffice_articles_path(q: "test")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/articles/:uuid" do
    it "returns success" do
      get backoffice_article_path(article)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/articles/:uuid/edit" do
    it "returns success" do
      get edit_backoffice_article_path(article)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT /backoffice/articles/:uuid" do
    it "updates featured" do
      put backoffice_article_path(article), params: { article: { featured: true } }
      expect(response).to redirect_to(backoffice_article_path(article))
      article.reload
      expect(article.featured).to be true
    end

    it "updates picked" do
      put backoffice_article_path(article), params: { article: { picked: true } }
      expect(response).to redirect_to(backoffice_article_path(article))
      article.reload
      expect(article.picked).to be true
    end

    it "can unpublish" do
      put backoffice_article_path(article), params: { article: { published: false } }
      article.reload
      expect(article.published).to be false
    end
  end

  describe "DELETE /backoffice/articles/:uuid" do
    it "deletes the article" do
      expect {
        delete backoffice_article_path(article)
      }.to change(Article, :count).by(-1)
      expect(response).to redirect_to(backoffice_articles_path)
    end
  end
end
