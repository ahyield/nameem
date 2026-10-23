require "rails_helper"

RSpec.describe "Backoffice::Comments", type: :request do
  let(:editor) { create(:editor) }
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: user) }
  let!(:comment) { create(:comment, article: article, user: user) }

  before { authenticate_user(editor) }

  describe "GET /backoffice/comments" do
    it "returns success" do
      get backoffice_comments_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by top_level" do
      get backoffice_comments_path(filter: "top_level")
      expect(response).to have_http_status(:ok)
    end

    it "filters by replies" do
      get backoffice_comments_path(filter: "replies")
      expect(response).to have_http_status(:ok)
    end

    it "searches by user name" do
      get backoffice_comments_path(q: user.name)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/comments/:id" do
    it "shows a comment" do
      get backoffice_comment_path(comment)
      expect(response).to have_http_status(:ok)
    end

    context "with replies" do
      before { create(:comment, :reply, article: article, user: user, parent: comment) }

      it "shows replies for top-level comment" do
        get backoffice_comment_path(comment)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /backoffice/comments/:id" do
    it "deletes the comment" do
      expect do
        delete backoffice_comment_path(comment)
      end.to change(Comment, :count).by(-1)
      expect(response).to redirect_to(backoffice_comments_path)
    end
  end
end
