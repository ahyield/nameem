require "rails_helper"

RSpec.describe "POST /api/views" do
  let(:article) { create(:article, :published) }

  def record_view(params)
    post api_views_path, params:, as: :json
  end

  it "records one view per visitor without signing in" do
    expect { record_view(viewable_type: "Article", viewable_id: article.id, visitor_id: "visitor-1") }
      .to change { article.reload.real_views_count }.by(1)
    expect(response).to have_http_status(:ok)

    expect { record_view(viewable_type: "Article", viewable_id: article.id, visitor_id: "visitor-1") }
      .not_to(change { article.reload.real_views_count })
  end

  it "counts different visitors separately" do
    record_view(viewable_type: "Article", viewable_id: article.id, visitor_id: "visitor-1")
    record_view(viewable_type: "Article", viewable_id: article.id, visitor_id: "visitor-2")

    expect(article.reload.real_views_count).to eq(2)
  end

  it "records profile views" do
    user = create(:user)

    expect { record_view(viewable_type: "User", viewable_id: user.id, visitor_id: "visitor-1") }
      .to change { user.reload.real_views_count }.by(1)
  end

  it "rejects types other than Article and User" do
    record_view(viewable_type: "Comment", viewable_id: create(:comment).id, visitor_id: "visitor-1")
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "rejects requests without a visitor id" do
    record_view(viewable_type: "Article", viewable_id: article.id)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "responds with not found for an unknown record" do
    record_view(viewable_type: "Article", viewable_id: 0, visitor_id: "visitor-1")
    expect(response).to have_http_status(:not_found)
  end
end
