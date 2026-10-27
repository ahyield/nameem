require "rails_helper"

RSpec.describe ArticlesController do
  let(:user) { create(:user, confirmed: true) }
  let(:unconfirmed_user) { create(:user, confirmed: false) }
  let(:another_user) { create(:user) }
  let(:article) { create(:article, user:) }

  before do
    sign_in user
  end

  describe "GET #new" do
    context "when user is confirmed" do
      it "returns a successful response" do
        get :new
        expect(response).to be_successful
      end
    end

    context "when user is not confirmed" do
      before do
        sign_in unconfirmed_user
      end

      it "redirects to the settings security page" do
        get :new
        expect(response).to redirect_to(settings_security_path)
      end
    end
  end

  describe "GET #edit" do
    context "when user is authorized to edit" do
      it "assigns the requested article to @article" do
        get :edit, params: { slug: user.slug, uuid: article.uuid }
        expect(assigns(:article)).to eq(article)
      end

      it "returns a successful response in HTML format" do
        get :edit, params: { slug: user.slug, uuid: article.uuid }
        expect(response).to be_successful
      end

      it "returns a successful response in JSON format" do
        get :edit, params: { slug: user.slug, uuid: article.uuid, format: :json }
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "when user is not authorized to edit" do
      before do
        sign_in another_user
      end

      it "responds with not found" do
        get :edit, params: { slug: user.slug, uuid: article.uuid }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH #update" do
    context "when user is authorized to update" do
      it "updates the article and redirects to the user article path" do
        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: true }
        article.reload
        expect(article.published).to be_truthy
        expect(response).to redirect_to(user_article_path(uuid: article.permalink_param, slug: user.slug))
      end

      it "sets the published_at date if not already set" do
        article.update(published_at: nil)
        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: true }
        article.reload
        expect(article.published_at).not_to be_nil
      end
    end

    context "when user is not authorized to update" do
      before do
        sign_in another_user
      end

      it "responds with not found" do
        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: true }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #show_modal" do
    it "assigns the requested article to @article" do
      get :show_modal, params: { slug: user.slug, uuid: article.uuid }
      expect(assigns(:article)).to eq(article)
    end

    it "returns a successful response" do
      get :show_modal, params: { slug: user.slug, uuid: article.uuid }
      expect(response).to be_successful
    end
  end
end
