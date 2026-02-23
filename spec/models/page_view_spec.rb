require "rails_helper"

RSpec.describe PageView do
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: user) }

  describe "validations" do
    it "is valid with valid attributes" do
      page_view = build(:page_view, viewable: article)
      expect(page_view).to be_valid
    end

    it "enforces visitor_id uniqueness per viewable" do
      create(:page_view, viewable: article, visitor_id: "abc123")
      duplicate = build(:page_view, viewable: article, visitor_id: "abc123")
      expect(duplicate).not_to be_valid
    end

    it "allows the same visitor_id for different viewables" do
      another_article = create(:article, :published, user: user)
      create(:page_view, viewable: article, visitor_id: "abc123")
      different_viewable = build(:page_view, viewable: another_article, visitor_id: "abc123")
      expect(different_viewable).to be_valid
    end
  end

  describe "counter cache" do
    it "increments real_views_count on the article" do
      expect {
        create(:page_view, viewable: article)
      }.to change { article.reload.real_views_count }.by(1)
    end

    it "increments real_views_count on the user" do
      expect {
        create(:page_view, viewable: user)
      }.to change { user.reload.real_views_count }.by(1)
    end
  end

  describe "associations" do
    it "belongs to viewable" do
      page_view = create(:page_view, viewable: article)
      expect(page_view.viewable).to eq(article)
    end
  end
end
