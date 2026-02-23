require "rails_helper"

RSpec.describe UsersController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let!(:article) { create(:article, :published, user:) }
  let!(:draft) { create(:article, :draft, user:) }

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { slug: user.slug }
      expect(response).to be_successful
    end

    it "assigns the requested user to @user" do
      get :show, params: { slug: user.slug }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "GET #article" do
    context "when the user is authorized" do
      before do
        sign_in user
      end

      it "returns a successful response" do
        get :article, params: { slug: user.slug, uuid: article.uuid }
        expect(response).to be_successful
      end

      it "assigns the requested article to @article" do
        get :article, params: { slug: user.slug, uuid: article.uuid }
        expect(assigns(:article)).to eq(article)
      end

      it "responds with JSON" do
        get :article, params: { slug: user.slug, uuid: article.uuid, format: :json }
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "when the user is not authorized" do
      before do
        sign_in another_user
      end

      it "raises a Pundit::NotAuthorizedError" do
        expect do
          article.unpublish
          get :article, params: { slug: user.slug, uuid: article.uuid }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET #articles" do
    it "returns a successful response" do
      get :articles, params: { slug: user.slug }, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns published articles to @articles" do
      get :articles, params: { slug: user.slug }, format: :turbo_stream
      expect(assigns(:articles)).to include(article)
      expect(assigns(:articles)).not_to include(draft)
    end
  end

  describe "GET #drafts" do
    before { sign_in user }

    it "returns a successful response" do
      get :drafts, params: { slug: user.slug }, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns draft articles to @articles" do
      get :drafts, params: { slug: user.slug }, format: :turbo_stream
      expect(assigns(:articles)).to include(draft)
      expect(assigns(:articles)).not_to include(article)
    end
  end

  describe "GET #stats" do
    context "when signed in as the profile owner" do
      before { sign_in user }

      it "returns a successful response" do
        get :stats, params: { slug: user.slug }
        expect(response).to be_successful
      end

      it "assigns aggregate stats" do
        get :stats, params: { slug: user.slug }
        expect(assigns(:total_views)).to eq(article.real_views_count)
        expect(assigns(:total_likes)).to eq(article.likes_count)
        expect(assigns(:total_comments)).to eq(article.comments_count)
        expect(assigns(:profile_views)).to eq(user.real_views_count)
      end

      it "assigns published articles" do
        get :stats, params: { slug: user.slug }
        expect(assigns(:articles)).to include(article)
        expect(assigns(:articles)).not_to include(draft)
      end
    end

    context "when signed in as another user" do
      before { sign_in another_user }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          get :stats, params: { slug: user.slug }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        get :stats, params: { slug: user.slug }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }

    it "destroys the requested article" do
      expect do
        delete :destroy, params: { slug: user.slug, uuid: article.uuid }
      end.to change(Article, :count).by(-1)
    end

    it "redirects to the user show page" do
      delete :destroy, params: { slug: user.slug, uuid: article.uuid }
      expect(response).to redirect_to(user_path(user))
    end
  end
end
