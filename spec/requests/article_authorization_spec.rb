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

  describe "GET /:slug/publish_modal/:uuid" do
    let(:draft) { create(:article, :draft, user: author) }

    it "renders for the author" do
      authenticate_user(author)

      get user_publish_modal_path(slug: author.slug, uuid: draft.uuid)
      expect(response).to have_http_status(:ok)
    end

    it "hides other users' drafts" do
      authenticate_user(create(:user))

      get user_publish_modal_path(slug: author.slug, uuid: draft.uuid)
      expect(response).to have_http_status(:not_found)
    end
  end
end
