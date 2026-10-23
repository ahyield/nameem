require "rails_helper"

RSpec.describe WeeklyDigest do
  let(:digest) { described_class.current }

  def article(**attributes)
    create(:article, :published, published_at: 2.days.ago, **attributes)
  end

  it "lists this week's trending articles, most read first" do
    quiet = article(real_views_count: 1)
    popular = article(real_views_count: 500)
    article(published_at: 3.weeks.ago, real_views_count: 9000)

    expect(digest.trending).to eq([popular, quiet])
  end

  it "adds this week's editors' picks that aren't already trending" do
    picked = article(picked: true)
    allow(digest).to receive(:trending).and_return([])

    expect(digest.picks).to eq([picked])
    allow(digest).to receive(:trending).and_return([picked])
    digest.instance_variable_set(:@picks, nil)
    expect(digest.picks).to be_empty
  end

  it "is only worth sending when at least three articles came out this week" do
    2.times { article }
    expect(digest).not_to be_worth_sending

    article
    expect(described_class.current).to be_worth_sending
  end

  it "goes to confirmed subscribers whose address works" do
    subscriber = create(:user)
    create(:user, email_weekly: false)
    create(:user, :unconfirmed)
    create(:user, email_suppressed_at: Time.current)

    expect(digest.audience).to contain_exactly(subscriber)
  end
end
