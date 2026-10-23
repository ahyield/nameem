require "rails_helper"

RSpec.describe "Bookmarks" do
  let(:author) { create(:user) }
  let(:article) { create(:article, :published, user: author) }
  let(:user) { create(:user) }

  describe "POST /:slug/:uuid/bookmark" do
    context "when signed in" do
      before { authenticate_user(user) }

      it "creates a bookmark" do
        expect do
          post user_bookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        end.to change(Bookmark, :count).by(1)
      end

      it "responds with turbo_stream" do
        post user_bookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "does not create duplicate bookmarks" do
        create(:bookmark, user: user, article: article)
        expect do
          post user_bookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        end.not_to change(Bookmark, :count)
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        post user_bookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE /:slug/:uuid/bookmark" do
    context "when signed in" do
      before { authenticate_user(user) }

      it "destroys the bookmark" do
        create(:bookmark, user: user, article: article)
        expect do
          delete user_unbookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        end.to change(Bookmark, :count).by(-1)
      end

      it "responds with turbo_stream" do
        create(:bookmark, user: user, article: article)
        delete user_unbookmark_article_path(slug: author, uuid: article), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "GET /:slug/bookmarks" do
    context "when viewing own bookmarks" do
      before { authenticate_user(user) }

      it "shows bookmarked articles" do
        create(:bookmark, user: user, article: article)
        get user_bookmarks_path(slug: user)
        expect(response).to have_http_status(:ok)
      end

      it "only shows published articles" do
        published_article = create(:article, :published, user: author, title: "مقال منشور للاختبار")
        draft = create(:article, user: author, published: false, title: "مسودة سرية للاختبار")
        create(:bookmark, user: user, article: draft)
        create(:bookmark, user: user, article: published_article)
        get user_bookmarks_path(slug: user)
        expect(response.body).to include("مقال منشور للاختبار")
        expect(response.body).not_to include("مسودة سرية للاختبار")
      end
    end

    context "when viewing another user's bookmarks" do
      let(:other_user) { create(:user) }

      before { authenticate_user(user) }

      it "denies access" do
        get user_bookmarks_path(slug: other_user)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        get user_bookmarks_path(slug: user)
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
