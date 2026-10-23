class Trending
  # Labelled «جديد» slots that give articles from the last day (Article.newcomers) a place in الرائج
  # before they have any engagement
  module Newcomers
    # 0-based positions in the trending tab and the feed sidebar
    TAB_SLOTS = [2, 5].freeze
    SIDEBAR_SLOTS = [2].freeze

    # Inserts newcomers at the given positions, never further down than right after the articles that
    # are actually trending (so a short trending list isn't followed by older articles first)
    def self.interleave(articles, newcomers, at:)
      trending = articles.count(&:trending_rank)
      list = articles.dup
      newcomers.zip(at).each_with_index do |(newcomer, position), index|
        list.insert([position, trending + index].min, newcomer)
      end
      list
    end
  end
end
