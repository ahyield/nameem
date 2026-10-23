require "rails_helper"

RSpec.describe CommentsController do
  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: author) }

  describe "POST #create" do
    context "when authenticated" do
      before { sign_in user }

      it "creates a comment and returns turbo_stream" do
        expect do
          post :create, params: { slug: author.slug, uuid: article.uuid, comment: { body: "تعليق جديد" } }, format: :turbo_stream
        end.to change(Comment, :count).by(1)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "rejects blank body" do
        expect do
          post :create, params: { slug: author.slug, uuid: article.uuid, comment: { body: "" } }, format: :turbo_stream
        end.not_to change(Comment, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when unauthenticated" do
      it "redirects to login" do
        post :create, params: { slug: author.slug, uuid: article.uuid, comment: { body: "تعليق" } }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated as comment author" do
      before { sign_in user }

      it "deletes the comment and returns turbo_stream" do
        comment = create(:comment, article: article, user: user)
        expect do
          delete :destroy, params: { slug: author.slug, uuid: article.uuid, id: comment.id }, format: :turbo_stream
        end.to change(Comment, :count).by(-1)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "when authenticated as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "can delete any comment" do
        comment = create(:comment, article: article, user: user)
        expect do
          delete :destroy, params: { slug: author.slug, uuid: article.uuid, id: comment.id }, format: :turbo_stream
        end.to change(Comment, :count).by(-1)
      end
    end

    context "when authenticated as another user" do
      let(:other_user) { create(:user) }

      before { sign_in other_user }

      it "cannot delete others comments" do
        comment = create(:comment, article: article, user: user)
        expect do
          delete :destroy, params: { slug: author.slug, uuid: article.uuid, id: comment.id }, format: :turbo_stream
        end.not_to change(Comment, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
