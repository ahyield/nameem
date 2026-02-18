require "rails_helper"

RSpec.describe ArticleLikesController do
  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: author) }

  describe "POST #create" do
    context "when authenticated" do
      before { sign_in user }

      it "creates a like and returns turbo_stream" do
        expect {
          post :create, params: { slug: author.slug, uuid: article.uuid }, format: :turbo_stream
        }.to change(ArticleLike, :count).by(1)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "prevents duplicate likes" do
        create(:article_like, user: user, article: article)
        expect {
          post :create, params: { slug: author.slug, uuid: article.uuid }, format: :turbo_stream
        }.not_to change(ArticleLike, :count)
      end

      it "prevents self-likes" do
        sign_in author
        expect {
          post :create, params: { slug: author.slug, uuid: article.uuid }, format: :turbo_stream
        }.not_to change(ArticleLike, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when unauthenticated" do
      it "redirects to login" do
        post :create, params: { slug: author.slug, uuid: article.uuid }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      before { sign_in user }

      it "removes the like and returns turbo_stream" do
        create(:article_like, user: user, article: article)
        expect {
          delete :destroy, params: { slug: author.slug, uuid: article.uuid }, format: :turbo_stream
        }.to change(ArticleLike, :count).by(-1)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
