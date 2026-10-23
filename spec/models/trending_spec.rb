require "rails_helper"

RSpec.describe Trending do
  # The excluded site account is identified by ID; keep it from matching test users by accident
  before { stub_const("Article::RANKING_EXCLUDED_USER_ID", 0) }

  def article(author = create(:user), **attributes)
    create(:article, :published, user: author, published_at: 10.days.ago, **attributes)
  end

  def view(article, at: 1.hour.ago, read_at: nil, user: nil)
    create(:page_view, viewable: article, created_at: at, read_at:, user:)
  end

  def like(article, at: 1.hour.ago, user: create(:user))
    create(:article_like, article:, user:, created_at: at)
  end

  def save(article, at: 1.hour.ago, user: create(:user))
    create(:bookmark, article:, user:, created_at: at)
  end

  def comment(article, at: 1.hour.ago, user: create(:user))
    create(:comment, article:, user:, created_at: at)
  end

  def ranked
    described_class.compute!
    Article.trending.to_a
  end

  it "ranks fresh activity above the same activity days ago" do
    today = article.tap { |a| 2.times { like(a) } }
    # Six likes five days ago have faded to about 3 points; two likes today are worth about 6
    last_week = article.tap { |a| 6.times { like(a, at: 5.days.ago) } }

    expect(ranked).to eq([today, last_week])
  end

  it "lets an old article with readers today outrank a new one nobody touched" do
    old = article(published_at: 1.year.ago).tap { |a| 2.times { view(a, read_at: 1.hour.ago) } }
    article(published_at: 1.hour.ago)

    expect(ranked).to eq([old])
  end

  it "weights reads over opens and saves over likes" do
    read = article.tap { |a| 2.times { view(a, read_at: 1.hour.ago) } }
    opened = article.tap { |a| 4.times { view(a) } }
    saved = article.tap { |a| 2.times { save(a) } }
    liked = article.tap { |a| 2.times { like(a) } }

    expect(ranked).to eq([saved, read, liked, opened])
  end

  it "ignores the author's own views, saves and comments" do
    author = create(:user)
    own = article(author)
    2.times { view(own, user: author) }
    save(own, user: author)
    comment(own, user: author)
    view(own)

    expect(ranked).to be_empty
  end

  it "counts one comment per person" do
    chatty_reader = create(:user)
    chatty = article.tap { |a| 3.times { comment(a, user: chatty_reader) } }
    2.times { view(chatty) }
    two_voices = article.tap { |a| 2.times { comment(a) } }

    # Counted once, the chatty reader's comment (5) plus two opens (about 2) stays under two commenters (10)

    expect(ranked).to eq([two_voices, chatty])
  end

  it "needs at least two people before an article can trend" do
    reader = create(:user)
    single = article
    view(single, user: reader)
    like(single, user: reader)

    expect(ranked).to be_empty
  end

  it "only looks at the last 14 days" do
    stale = article.tap { |a| 3.times { like(a, at: 15.days.ago) } }
    expect(ranked).not_to include(stale)
  end

  it "keeps any author to two trending articles" do
    prolific = create(:user)
    theirs = Array.new(3) { |i| article(prolific).tap { |a| (5 - i).times { like(a) } } }
    other = article.tap { |a| 2.times { like(a) } }

    expect(ranked).to eq([theirs[0], theirs[1], other])
  end

  it "skips articles people only passed by" do
    article.tap { |a| 2.times { view(a) } }
    expect(ranked).to be_empty
  end

  it "ranks at most twenty articles" do
    articles = Array.new(21) { |i| article.tap { |a| (i.zero? ? 2 : 3).times { like(a) } } }
    expect(ranked).to match_array(articles.drop(1))
  end

  it "leaves out the site account and drafts" do
    site = create(:user)
    stub_const("Article::RANKING_EXCLUDED_USER_ID", site.id)
    article(site).tap { |a| 2.times { like(a) } }
    create(:article, :draft).tap { |a| 2.times { like(a) } }

    expect(ranked).to be_empty
  end

  it "replaces the previous ranking and stores the score" do
    fading = article.tap { |a| 2.times { like(a) } }
    described_class.compute!
    ArticleLike.where(article: fading).delete_all

    rising = article.tap { |a| 2.times { save(a) } }
    expect(ranked).to eq([rising])
    expect(fading.reload.trending_rank).to be_nil
    expect(rising.reload.trending_score).to be > 7
  end

  it "is refreshed by RefreshTrendingJob" do
    trending = article.tap { |a| 2.times { like(a) } }

    RefreshTrendingJob.perform_now
    expect(trending.reload.trending_rank).to eq(1)
  end
end
