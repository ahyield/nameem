require "rails_helper"

RSpec.describe "Turning comments off on an article" do
  let(:author) { create(:user) }
  let(:reader) { create(:user) }
  let(:article) { create(:article, :published, user: author) }
  let(:closed_article) { create(:article, :published, :comments_disabled, user: author) }

  describe "PUT /:slug/:uuid (publish dialog)" do
    it "turns comments off and back on" do
      authenticate_user(author)

      put user_update_article_path(slug: author.slug, uuid: article.uuid), params: { publish: true, comments_enabled: "0" }
      expect(article.reload.comments_enabled).to be(false)

      put user_update_article_path(slug: author.slug, uuid: article.uuid), params: { publish: true, comments_enabled: "1" }
      expect(article.reload.comments_enabled).to be(true)
    end

    it "leaves the setting alone when the field isn't sent" do
      authenticate_user(author)

      put user_update_article_path(slug: author.slug, uuid: closed_article.uuid), params: { publish: true }
      expect(closed_article.reload.comments_enabled).to be(false)
    end

    it "does not let another user change it" do
      authenticate_user(reader)

      put user_update_article_path(slug: author.slug, uuid: article.uuid), params: { publish: true, comments_enabled: "0" }
      expect(response).to have_http_status(:not_found)
      expect(article.reload.comments_enabled).to be(true)
    end
  end

  describe "GET /:slug/publish_modal/:uuid" do
    before { authenticate_user(author) }

    it "shows the checkbox ticked when comments are on" do
      get user_publish_modal_path(slug: author.slug, uuid: article.uuid)
      expect(response.body).to include('type="checkbox" name="comments_enabled" id="comments_enabled" value="1"')
      expect(response.body).to match(/name="comments_enabled"[^>]*checked/)
    end

    it "shows the checkbox unticked when comments are off" do
      get user_publish_modal_path(slug: author.slug, uuid: closed_article.uuid)
      expect(response.body).to include('name="comments_enabled"')
      expect(response.body).not_to match(/type="checkbox"[^>]*name="comments_enabled"[^>]*checked/)
    end
  end

  describe "POST /:slug/:uuid/comments" do
    before { authenticate_user(reader) }

    it "refuses new comments when comments are off" do
      expect do
        post user_article_comments_path(slug: author, uuid: closed_article),
             params: { comment: { body: "تعليق" } },
             as:     :turbo_stream
      end.not_to change(Comment, :count)
      expect(response).to have_http_status(:forbidden)
    end

    it "refuses replies when comments are off" do
      parent = create(:comment, article: closed_article)

      expect do
        post user_article_comments_path(slug: author, uuid: closed_article),
             params: { comment: { body: "رد", parent_id: parent.id } },
             as:     :turbo_stream
      end.not_to change(Comment, :count)
      expect(response).to have_http_status(:forbidden)
    end

    it "accepts comments when comments are on" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "تعليق" } },
             as:     :turbo_stream
      end.to change(Comment, :count).by(1)
    end
  end

  describe "GET /:slug/:uuid" do
    before do
      create(:comment, article: closed_article, body: "تعليق سابق")
      authenticate_user(reader)
    end

    it "keeps existing comments but shows no forms" do
      get user_article_path(slug: author, uuid: closed_article.permalink_param)

      expect(response.body).to include("تعليق سابق")
      expect(response.body).to include("التعليقات مغلقة على هذا الموضوع")
      expect(response.body).not_to include('id="comment_form"')
      expect(response.body).not_to include("reply_form_comment_")
    end

    it "shows the forms when comments are on" do
      create(:comment, article:)
      get user_article_path(slug: author, uuid: article.permalink_param)

      expect(response.body).not_to include("التعليقات مغلقة على هذا الموضوع")
      expect(response.body).to include('id="comment_form"')
      expect(response.body).to include("reply_form_comment_")
    end
  end
end
