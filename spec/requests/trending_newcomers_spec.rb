require "rails_helper"

RSpec.describe "New articles in الرائج" do
  let(:reader) { create(:user) }

  before do
    stub_const("Article::RANKING_EXCLUDED_USER_ID", 0)
    authenticate_user(reader)
  end

  def trending(count)
    Array.new(count) { |i| create(:article, :published, title: "رائج #{i + 1}", published_at: 5.days.ago, trending_rank: i + 1) }
  end

  def card_titles
    response.body.scan(/رائج \d+|جديد [أب]/)
  end

  it "puts new articles third and sixth on the tab, labelled, then ends with a way to الأحدث" do
    trending(6)
    create(:article, :published, title: "جديد أ", published_at: 1.hour.ago)
    create(:article, :published, title: "جديد ب", published_at: 2.hours.ago)

    get trending_feed_path(format: :turbo_stream)

    expect(card_titles.first(8)).to eq(["رائج 1", "رائج 2", "جديد أ", "رائج 3", "رائج 4", "جديد ب", "رائج 5", "رائج 6"])
    expect(response.body.scan(">جديد<").size).to eq(2)
    expect(response.body).to include("هذا كل ما يتداوله القرّاء الآن", "تصفّح الأحدث", latest_feed_path)
    expect(response.body).not_to include("feed_pagination")
  end

  it "shows only new articles when nothing is trending, not older ones" do
    create(:article, :published, title: "قديم", published_at: 3.days.ago)
    create(:article, :published, title: "جديد أ", published_at: 1.hour.ago)

    get trending_feed_path(format: :turbo_stream)
    expect(response.body).to include("جديد أ")
    expect(response.body).not_to include("قديم")
  end

  it "says so when nothing is trending or new" do
    create(:article, :published, published_at: 3.days.ago)

    get trending_feed_path(format: :turbo_stream)
    expect(response.body).to include("لا شيء رائج الآن", "تصفّح الأحدث")
  end

  it "gives one sidebar slot to a new article, keeping five entries" do
    trending(5)
    create(:article, :published, title: "جديد أ", published_at: 1.hour.ago)

    get feed_index_path

    sidebar = response.body[/الرائج هذا الأسبوع.*?<\/ol>/m]
    expect(sidebar.scan(/رائج \d+|جديد أ/)).to eq(["رائج 1", "رائج 2", "جديد أ", "رائج 3", "رائج 4"])
    expect(sidebar).to include(">جديد<")
    expect(sidebar.scan(%r{>(0\d)</span>}).flatten).to eq(%w[01 02 03 04])
  end
end
