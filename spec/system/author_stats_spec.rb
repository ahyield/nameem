require "rails_helper"

RSpec.describe "Author stats" do
  let(:author) { create(:user) }

  before do
    create(:article, :published, user: author, title: "الأحدث", published_at: 1.day.ago)
      .update_column(:real_views_count, 3)
    create(:article, :published, user: author, title: "الأكثر قراءة", published_at: 1.month.ago)
      .update_column(:real_views_count, 50)
    system_sign_in(author)
  end

  it "badges the most viewed article and sorts by views" do
    visit user_stats_path(author)

    within("tr", text: "الأكثر قراءة") { expect(page).to have_content("الأكثر مشاهدة") }
    within("tr", text: "الأحدث") { expect(page).to have_no_content("الأكثر مشاهدة") }

    click_on "المشاهدات"
    titles = all("tbody tr td:first-child").map(&:text)
    expect(titles.first).to include("الأكثر قراءة")

    click_on "المشاهدات"
    titles = all("tbody tr td:first-child").map(&:text)
    expect(titles.first).to include("الأحدث")
  end
end
