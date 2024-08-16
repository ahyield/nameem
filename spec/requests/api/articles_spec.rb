require "rails_helper"

RSpec.describe "Api::Articles" do
  let(:user) { create(:user, confirmed: true) }
  let(:another_user) { create(:user, confirmed: true) }
  let(:article) { create(:article, user:) }

  describe "GET /api/articles/:slug/:uuid" do
    it "returns the article as JSON" do
      get "/api/articles/#{user.slug}/#{article.uuid}"
      expect(response).to have_http_status(:success)
      expect(json["id"]).to eq(article.id)
    end
  end

  describe "GET /api/articles/new" do
    it "returns a new article and the current user as JSON" do
      authenticate_user(user)
      get "/api/articles/new"
      expect(response).to have_http_status(:success)
      expect(json["article"]["uuid"]).not_to be_nil
      expect(json["user"]["id"]).to eq(user.id)
    end
  end

  describe "GET /api/articles/:slug/:uuid/edit" do
    context "when user is authorized to edit" do
      before do
        authenticate_user(user)
      end

      it "returns the article as JSON" do
        get "/api/articles/#{user.slug}/#{article.uuid}/edit"
        expect(response).to have_http_status(:success)
        expect(json["id"]).to eq(article.id)
      end
    end

    context "when user is not authorized to edit" do
      before do
        authenticate_user(another_user)
      end

      it "raises a Pundit::NotAuthorizedError" do
        get "/api/articles/#{user.slug}/#{article.uuid}/edit"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/articles/:slug/:uuid" do
    context "when user is authorized to update" do
      before do
        authenticate_user(user)
      end

      context "with valid parameters" do
        it "updates the article and returns it as JSON" do
          put "/api/articles/#{user.slug}/#{article.uuid}", params: { article: { title: "Updated Title" } }
          article.reload
          expect(article.title).to eq("Updated Title")
          expect(response).to have_http_status(:success)
          expect(json["title"]).to eq("Updated Title")
        end
      end
    end

    context "when user is not authorized to update" do
      before do
        authenticate_user(another_user)
        allow(ArticlePolicy).to receive(:new).and_return(instance_double(ArticlePolicy, update?: false))
      end

      it "raises a Pundit::NotAuthorizedError" do
        put "/api/articles/#{user.slug}/#{article.uuid}", params: { article: { title: "New Updated Title" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
