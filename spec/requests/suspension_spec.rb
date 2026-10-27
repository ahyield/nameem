require "rails_helper"

RSpec.describe "Suspended users" do
  let(:author) { create(:user) }
  let(:suspended) { create(:user, :suspended) }
  let(:article) { create(:article, :published, user: author) }
  let(:comment) { create(:comment, article:, user: author) }

  before { authenticate_user(suspended) }

  it "cannot comment" do
    expect do
      post user_article_comments_path(slug: author, uuid: article), params: { comment: { body: "تعليق" } }, as: :turbo_stream
    end.not_to change(Comment, :count)
    expect(response).to have_http_status(:forbidden)
  end

  it "cannot like articles or comments" do
    post user_like_article_path(slug: author, uuid: article), as: :turbo_stream
    expect(response).to have_http_status(:forbidden)

    post user_like_comment_path(slug: author, uuid: article, id: comment.id), as: :turbo_stream
    expect(response).to have_http_status(:forbidden)
    expect(ArticleLike.count + CommentLike.count).to eq(0)
  end

  it "cannot publish" do
    draft = create(:article, :draft, user: suspended)

    put user_update_article_path(slug: suspended.slug, uuid: draft.uuid), params: { publish: true }
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("حسابك موقوف حالياً")
    expect(draft.reload).not_to be_published
  end

  it "cannot write through the editor API" do
    post "/api/articles", as: :json
    expect(response).to have_http_status(:forbidden)

    draft = create(:article, :draft, user: suspended)
    put "/api/articles/#{suspended.slug}/#{draft.uuid}", params: { article: { title: "جديد" } }, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "can still read and sees a notice" do
    get user_article_path(slug: author, uuid: article.permalink_param)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("حسابك موقوف حالياً")
  end
end
