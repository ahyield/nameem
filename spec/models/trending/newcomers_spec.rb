require "rails_helper"

RSpec.describe Trending::Newcomers do
  describe ".interleave" do
    let(:ranked) { Array.new(6) { |i| build(:article, trending_rank: i + 1) } }
    let(:newcomers) { build_list(:article, 2) }

    it "puts newcomers at the given positions" do
      list = described_class.interleave(ranked, newcomers, at: [2, 5])

      expect(list.index(newcomers[0])).to eq(2)
      expect(list.index(newcomers[1])).to eq(5)
      expect(list.size).to eq(8)
    end

    it "puts them right after a short trending list, ahead of older articles" do
      short = [build(:article, trending_rank: 1), build(:article), build(:article)]
      list = described_class.interleave(short, newcomers, at: [2, 5])

      expect(list[1..2]).to eq(newcomers)
    end

    it "leaves the list alone without newcomers" do
      expect(described_class.interleave(ranked, [], at: [2, 5])).to eq(ranked)
    end
  end
end
