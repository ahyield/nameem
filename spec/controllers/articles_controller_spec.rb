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
    context "with the publish dialog's advanced settings" do
      render_views

      let(:article) do
        create(:article, user:, title: "رحلة", content_html: '<img src="https://example.com/a.jpg"><img src="https://example.com/b.jpg">')
      end

      it "saves the search title, address, share image, original address and visibility" do
        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: true,
                                 seo: { title: "عنوان للبحث", slug: "رحلةٌ جميلة!", cover_image_src: "https://example.com/b.jpg",
                                        canonical_url: "https://example.com/original", noindex: "1" } }

        expect(article.reload).to have_attributes(seo_title: "عنوان للبحث", slug: "رحلة-جميلة", noindex: true,
                                                  cover_image_src: "https://example.com/b.jpg",
                                                  canonical_url: "https://example.com/original")
        expect(response).to redirect_to(user_article_path(slug: user.slug, uuid: "رحلة-جميلة-#{article.short_id}"))
      end

      it "goes back to the title's words and the first image when those are cleared" do
        article.update!(slug: "قديم", cover_image_src: "https://example.com/b.jpg")

        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: false,
                                 seo: { slug: "", cover_image_src: "", noindex: "0" } }

        expect(article.reload).to have_attributes(slug: "رحلة", cover_image_src: nil, noindex: false)
      end

      it "shows the dialog again with the problem when a setting isn't valid" do
        patch :update, params: { slug: user.slug, uuid: article.uuid, publish: true, tag_names: ["سفر"],
                                 seo: { canonical_url: "https://nameem.com/x" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("لموقع غير نميم", "سفر")
        expect(article.reload.published).to be(false)
      end
    end

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
