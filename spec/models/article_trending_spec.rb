require "rails_helper"

RSpec.describe Article, ".trending" do
  let(:author) { create(:user) }

  # The excluded account is identified by ID; keep it from matching test users by accident
  before { stub_const("Article::RANKING_EXCLUDED_USER_ID", 0) }

  it "leaves out the site's own account" do
    site_account = create(:user)
    stub_const("Article::RANKING_EXCLUDED_USER_ID", site_account.id)
    create(:article, :published, user: site_account, published_at: 1.day.ago)

    expect(described_class.trending).to be_empty
  end

  it "returns articles published within the last 7 days" do
    recent = create(:article, :published, user: author, published_at: 3.days.ago)

    expect(described_class.trending).to include(recent)
  end

  it "excludes articles older than 7 days when recent ones exist" do
    recent = create(:article, :published, user: author, published_at: 1.day.ago)
    old = create(:article, :published, user: author, published_at: 8.days.ago)

    expect(described_class.trending).to include(recent)
    expect(described_class.trending).not_to include(old)
  end

  it "excludes unpublished articles" do
    draft = create(:article, :draft, user: author, published_at: 1.day.ago)

    expect(described_class.trending).not_to include(draft)
  end

  it "favors newer articles with equal engagement over older ones" do
    old = create(:article, :published, user: author, published_at: 5.days.ago,
                 real_views_count: 50, likes_count: 5, comments_count: 2)
    fresh = create(:article, :published, user: author, published_at: 2.hours.ago,
                   real_views_count: 50, likes_count: 5, comments_count: 2)

    results = described_class.trending.to_a
    expect(results.index(fresh)).to be < results.index(old)
  end

  it "ranks a highly-engaged older article above a low-engagement new one" do
    viral = create(:article, :published, user: author, published_at: 3.days.ago,
                   real_views_count: 500, likes_count: 100, comments_count: 50)
    quiet = create(:article, :published, user: author, published_at: 1.hour.ago,
                   real_views_count: 2, likes_count: 0, comments_count: 0)

    results = described_class.trending.to_a
    expect(results.index(viral)).to be < results.index(quiet)
  end

  it "falls back to 30 days when no articles in last 7 days" do
    older = create(:article, :published, user: author, published_at: 10.days.ago)

    expect(described_class.trending).to include(older)
  end

  it "falls back to 90 days when no articles in last 30 days" do
    old = create(:article, :published, user: author, published_at: 60.days.ago)

    expect(described_class.trending).to include(old)
  end

  it "returns empty when no articles in last 90 days" do
    ancient = create(:article, :published, user: author, published_at: 91.days.ago)

    expect(described_class.trending).not_to include(ancient)
  end

  it "trending_within respects the exact days parameter without fallback" do
    old_but_in_range = create(:article, :published, user: author, published_at: 12.days.ago)

    expect(described_class.trending_within(7)).not_to include(old_but_in_range)
    expect(described_class.trending_within(14)).to include(old_but_in_range)
  end

  it "weighs likes more than views and comments more than likes" do
    views_heavy = create(:article, :published, user: author, published_at: 1.day.ago,
                         real_views_count: 100, likes_count: 0, comments_count: 0)
    likes_heavy = create(:article, :published, user: author, published_at: 1.day.ago,
                         real_views_count: 0, likes_count: 34, comments_count: 0)
    comments_heavy = create(:article, :published, user: author, published_at: 1.day.ago,
                            real_views_count: 0, likes_count: 0, comments_count: 21)

    results = described_class.trending.to_a
    # comments_count * 5 = 105 > likes_count * 3 = 102 > views_count = 100
    expect(results.index(comments_heavy)).to be < results.index(likes_heavy)
    expect(results.index(likes_heavy)).to be < results.index(views_heavy)
  end

  it "can be chained with limit" do
    6.times { |i| create(:article, :published, user: author, published_at: i.hours.ago) }

    expect(described_class.trending.limit(5).size).to eq(5)
  end
end
