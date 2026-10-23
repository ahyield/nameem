require "rails_helper"

RSpec.describe Article, ".newcomers" do
  before { stub_const("Article::RANKING_EXCLUDED_USER_ID", 0) }

  def published(at, **attributes)
    create(:article, :published, published_at: at, **attributes)
  end

  it "picks untrending articles from the last day, newest first" do
    older = published(5.hours.ago)
    newest = published(1.hour.ago)
    published(2.days.ago)
    published(2.hours.ago, trending_rank: 1)
    create(:article, :draft, published_at: 1.hour.ago)

    expect(described_class.newcomers(limit: 5)).to eq([newest, older])
  end

  it "takes one per author and respects the limit" do
    author = create(:user)
    latest = published(1.hour.ago, user: author)
    published(2.hours.ago, user: author)
    other = published(3.hours.ago)
    published(4.hours.ago)

    expect(described_class.newcomers(limit: 2)).to eq([latest, other])
  end

  it "leaves out the site account" do
    site = create(:user)
    stub_const("Article::RANKING_EXCLUDED_USER_ID", site.id)
    published(1.hour.ago, user: site)

    expect(described_class.newcomers(limit: 2)).to be_empty
  end
end
