require "rails_helper"

RSpec.describe "Backoffice::Tags", type: :request do
  let(:editor) { create(:editor) }
  let!(:tag) { create(:tag) }

  before { authenticate_user(editor) }

  describe "GET /backoffice/tags" do
    it "returns success" do
      get backoffice_tags_path
      expect(response).to have_http_status(:ok)
    end

    it "searches by name" do
      get backoffice_tags_path(q: tag.name)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/tags/:slug" do
    it "returns success" do
      get backoffice_tag_path(tag)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/tags/:slug/edit" do
    it "returns success" do
      get edit_backoffice_tag_path(tag)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT /backoffice/tags/:slug" do
    it "updates the tag name" do
      put backoffice_tag_path(tag), params: { tag: { name: "اسم-جديد" } }
      tag.reload
      expect(tag.name).to eq("اسم-جديد")
      expect(response).to redirect_to(backoffice_tag_path(tag))
    end
  end

  describe "POST /backoffice/tags/:slug/merge" do
    let!(:target_tag) { create(:tag) }
    let(:user) { create(:user) }
    let!(:article) { create(:article, :published, user: user) }
    let!(:article_tag) { create(:article_tag, article: article, tag: tag) }

    it "merges the tag into target" do
      post merge_backoffice_tag_path(tag), params: { target_id: target_tag.id }
      expect(response).to redirect_to(backoffice_tag_path(target_tag))
      expect(Tag.exists?(tag.id)).to be false
      expect(article.tags.reload).to include(target_tag)
    end
  end

  describe "DELETE /backoffice/tags/:slug" do
    it "deletes the tag" do
      expect {
        delete backoffice_tag_path(tag)
      }.to change(Tag, :count).by(-1)
      expect(response).to redirect_to(backoffice_tags_path)
    end
  end
end
