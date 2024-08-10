require "rails_helper"

RSpec.describe Backoffice::ArticlesController do
  let(:admin_user) { create(:user, editor: true) }
  let(:regular_user) { create(:user, editor: false) }
  let(:article_user) { create(:user) }
  let(:article) { create(:article, user: article_user) }

  describe "GET #index" do
    context "when user is an admin" do
      before do
        sign_in admin_user
      end

      it "assigns published articles to @articles" do
        get :index
        article.publish
        expect(assigns(:articles)).to eq([article])
      end

      it "returns a successful response" do
        get :index
        expect(response).to be_successful
      end
    end

    context "when user is not an admin" do
      before do
        sign_in regular_user
      end

      it "redirects to the home page with an error" do
        get :index
        expect(response).to redirect_to("/")
        expect(flash[:error]).to eq("غير مسموح لك بالدخول إلى هذه الصفحة")
      end
    end
  end

  describe "GET #edit" do
    context "when user is an admin" do
      before do
        sign_in admin_user
      end

      it "assigns the requested article to @article" do
        get :edit, params: { user_slug: article_user.slug, uuid: article.uuid }
        expect(assigns(:article)).to eq(article)
      end

      it "returns a successful response" do
        get :edit, params: { user_slug: article_user.slug, uuid: article.uuid }
        expect(response).to be_successful
      end
    end

    context "when user is not an admin" do
      before do
        sign_in regular_user
      end

      it "redirects to the home page with an error" do
        get :edit, params: { user_slug: article_user.slug, uuid: article.uuid }
        expect(response).to redirect_to("/")
        expect(flash[:error]).to eq("غير مسموح لك بالدخول إلى هذه الصفحة")
      end
    end
  end

  describe "PATCH #update" do
    context "when user is an admin" do
      before do
        sign_in admin_user
      end

      context "with valid parameters" do
        it "updates the article and redirects" do
          patch :update, params: { user_slug: article_user.slug, uuid: article.uuid, article: { picked: true } }
          article.reload
          expect(article.picked).to be_truthy
          expect(response).to redirect_to(backoffice_articles_path)
          expect(flash[:notice]).to eq("تم تحديث البيانات بنجاح")
        end
      end

      context "with invalid parameters" do
        it "renders the edit template with an error" do
          patch :update, params: { user_slug: article_user.slug, uuid: article.uuid, article: { featured: nil } }

          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("حدث خطأ أثناء تحديث البيانات")
        end
      end
    end

    context "when user is not an admin" do
      before do
        sign_in regular_user
      end

      it "redirects to the home page with an error" do
        patch :update, params: { user_slug: article_user.slug, uuid: article.uuid, article: { picked: true } }
        expect(response).to redirect_to("/")
        expect(flash[:error]).to eq("غير مسموح لك بالدخول إلى هذه الصفحة")
      end
    end
  end
end
