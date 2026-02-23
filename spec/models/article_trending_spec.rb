require "rails_helper"

RSpec.describe "Article.trending" do
  let(:author) { create(:user) }

  it "returns articles published within the last 7 days" do
    recent = create(:article, :published, user: author, published_at: 3.days.ago)

    expect(Article.trending).to include(recent)
  end

  it "excludes articles older than 7 days" do
    old = create(:article, :published, user: author, published_at: 8.days.ago)

    expect(Article.trending).not_to include(old)
  end

  it "excludes unpublished articles" do
    draft = create(:article, :draft, user: author, published_at: 1.day.ago)

    expect(Article.trending).not_to include(draft)
  end

  it "excludes system user articles (user_id: 1)" do
    system_user = create(:user, id: 1)
    system_article = create(:article, :published, user: system_user, published_at: 1.day.ago)

    expect(Article.trending).not_to include(system_article)
  end

  it "favors newer articles with equal engagement over older ones" do
    old = create(:article, :published, user: author, published_at: 5.days.ago,
                 real_views_count: 50, likes_count: 5, comments_count: 2)
    fresh = create(:article, :published, user: author, published_at: 2.hours.ago,
                   real_views_count: 50, likes_count: 5, comments_count: 2)

    results = Article.trending.to_a
    expect(results.index(fresh)).to be < results.index(old)
  end

  it "ranks a highly-engaged older article above a low-engagement new one" do
    viral = create(:article, :published, user: author, published_at: 3.days.ago,
                   real_views_count: 500, likes_count: 100, comments_count: 50)
    quiet = create(:article, :published, user: author, published_at: 1.hour.ago,
                   real_views_count: 2, likes_count: 0, comments_count: 0)

    results = Article.trending.to_a
    expect(results.index(viral)).to be < results.index(quiet)
  end

  it "returns empty when no recent articles exist" do
    create(:article, :published, user: author, published_at: 10.days.ago)

    expect(Article.trending).to be_empty
  end
end
