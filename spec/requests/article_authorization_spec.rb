require "rails_helper"

RSpec.describe "Article authorization" do
  let(:author) { create(:user) }
  let!(:article) { create(:article, :published, user: author) }

  describe "DELETE /:slug/:uuid" do
    it "lets the author delete their article" do
      authenticate_user(author)

      expect { delete user_destroy_article_path(slug: author.slug, uuid: article.uuid) }
        .to change(Article, :count).by(-1)
      expect(response).to redirect_to(user_path(author))
    end

    it "does not let another user delete it" do
      authenticate_user(create(:user))

      expect { delete user_destroy_article_path(slug: author.slug, uuid: article.uuid) }
        .not_to change(Article, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "requires signing in" do
      expect { delete user_destroy_article_path(slug: author.slug, uuid: article.uuid) }
        .not_to change(Article, :count)
    end

    it "responds with not found for an unknown article" do
      authenticate_user(author)

      delete user_destroy_article_path(slug: author.slug, uuid: SecureRandom.uuid)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /:slug/:uuid (publish dialog)" do
    it "keeps the description the author wrote" do
      article.update(content_html: "<p>نص المقال الطويل هنا</p>")
      authenticate_user(author)

      put user_update_article_path(slug: author.slug, uuid: article.uuid),
          params: { publish: true, description: "وصف كتبه الكاتب" }
      expect(article.reload.description).to eq("وصف كتبه الكاتب")
    end
  end

  describe "GET /:slug/publish_modal/:uuid" do
    let(:draft) { create(:article, :draft, user: author) }

    it "renders for the author" do
      authenticate_user(author)

      get user_publish_modal_path(slug: author.slug, uuid: draft.uuid)
      expect(response).to have_http_status(:ok)
    end

    it "offers to publish a draft or keep it as a draft" do
      authenticate_user(author)
      get user_publish_modal_path(slug: author.slug, uuid: draft.uuid)

      expect(response.body).to match(%r{value="true"[^>]*>\s*نشر\s*</button>})
      expect(response.body).to include("حفظ كمسودة")
    end

    it "offers to save changes or unpublish a published article" do
      authenticate_user(author)
      get user_publish_modal_path(slug: author.slug, uuid: article.uuid)

      expect(response.body).to match(%r{value="true"[^>]*>\s*نشر\s*</button>})
      expect(response.body).to include("إلغاء النشر")
      expect(response.body).not_to include("حفظ كمسودة")
    end

    it "explains why a draft without a title can't be published" do
      untitled = create(:article, :draft, user: author, title: nil, content_html: nil)
      authenticate_user(author)
      get user_publish_modal_path(slug: author.slug, uuid: untitled.uuid)

      expect(response.body).to match(/<button type="submit" name="publish" value="true" disabled/)
      expect(response.body).to include("أضف عنواناً لموضوعك لتتمكن من نشره")
    end

    it "hides other users' drafts" do
      authenticate_user(create(:user))

      get user_publish_modal_path(slug: author.slug, uuid: draft.uuid)
      expect(response).to have_http_status(:not_found)
    end
  end
end
