require "rails_helper"

RSpec.describe StatsHelper do
  let(:user) { create(:user) }

  def header(label, key, sort:, direction:)
    Nokogiri::HTML.fragment(helper.stats_sort_header(label, key, user:, sort:, direction:)).at("th")
  end

  it "marks the active column and links to the opposite direction" do
    th = header("المشاهدات", "views", sort: "views", direction: :desc)

    expect(th["aria-sort"]).to eq("descending")
    expect(th.at("a")["href"]).to include("sort=views", "direction=asc", "#articles")
    expect(th.text).to include("↓")
  end

  it "sorts an inactive column descending first, without aria-sort" do
    th = header("الإعجابات", "likes", sort: "views", direction: :desc)

    expect(th["aria-sort"]).to be_nil
    expect(th.at("a")["href"]).to include("sort=likes", "direction=desc")
  end
end
