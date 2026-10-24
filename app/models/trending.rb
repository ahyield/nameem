# Ranks articles for الرائج by recent engagement. Every like, save, comment, open and read from the last
# 14 days counts, fading with a 48-hour half-life, so an older article that's being read again can trend
# and yesterday's peak fades. The author's own activity never counts. Results are stored on articles
# (trending_score, trending_rank) by RefreshTrendingJob.
class Trending
  WINDOW = 14.days
  HALF_LIFE_MINUTES = 48 * 60
  WEIGHTS = { open: 1, read: 3, like: 3, save: 4, comment: 5 }.freeze
  # People who engaged with an article before it can trend, so one visitor can't make a trend
  MIN_PEOPLE = 2
  # Below this an article is just being passed by: two opens score about 2, one real read 4, a like 3
  MIN_SCORE = 3
  # Stability, so the list doesn't flicker on single views: an article already trending stays until it
  # drops below STAY_SCORE, and a newcomer has to beat it by INCUMBENT_MARGIN to take its place
  STAY_SCORE = 2
  INCUMBENT_MARGIN = 0.2
  # At most this many articles are ranked as trending; any one author gets at most AUTHOR_CAP of them
  MAX_RANKED = 20
  AUTHOR_CAP = 2
  # Nameem is Arabic first: mostly-English articles (ArticleLanguage) need about 4× the engagement to trend
  LATIN_WEIGHT = 0.25

  def self.compute!(now: Time.current)
    new(now).compute!
  end

  def initialize(now)
    @now = now
    @since = now - WINDOW
  end

  # Returns the ranked article ids, best first
  def compute!
    scores, people = tally
    Article.where(id: scores.keys, mostly_latin: true).pluck(:id).each { |id| scores[id] *= LATIN_WEIGHT }
    incumbents = Article.where.not(trending_rank: nil).pluck(:id).to_set
    eligible = scores.select do |id, score|
      people[id] >= MIN_PEOPLE && score >= (incumbents.include?(id) ? STAY_SCORE : MIN_SCORE)
    end
    ranked = diversify(rank_with_incumbency(eligible, incumbents))
    store(ranked, eligible)
    ranked
  end

  private

  # Articles already trending sort as if they scored INCUMBENT_MARGIN more; the stored score stays the real one
  def rank_with_incumbency(scores, incumbents)
    scores.sort_by do |id, score|
      [-(incumbents.include?(id) ? score * (1 + INCUMBENT_MARGIN) : score), -id]
    end.map(&:first)
  end

  # score and distinct people per article, summed across signals
  def tally
    scores = Hash.new(0.0)
    people = Hash.new(0)
    signals.each do |rows|
      rows.each do |article_id, score, count|
        scores[article_id] += score.to_f
        people[article_id] = [people[article_id], count.to_i].max
      end
    end
    [scores, people]
  end

  def signals
    [views, by_user(ArticleLike, :likes), by_user(Bookmark, :bookmarks), comments]
  end

  # Opens and reads, one per visitor; the author's own visits are skipped when we know who they are
  def views
    PageView.joins("INNER JOIN articles ON articles.id = page_views.viewable_id")
            .where(viewable_type: "Article", created_at: @since..)
            .merge(candidates)
            .where("page_views.user_id IS NULL OR page_views.user_id <> articles.user_id")
            .group("page_views.viewable_id")
            .pluck(Arel.sql("page_views.viewable_id"), score(:views), Arel.sql("COUNT(DISTINCT page_views.visitor_id)"))
  end

  # Likes and saves: one per user, never the author's own
  def by_user(model, signal)
    model.joins(:article).merge(candidates)
         .where(created_at: @since..)
         .where(model.arel_table[:user_id].not_eq(Article.arel_table[:user_id]))
         .group(:article_id)
         .pluck(:article_id, score(signal), model.arel_table[:user_id].count(true))
  end

  # One per commenter (their latest comment), never the author replying on their own article
  def comments
    latest = Comment.joins(:article).merge(candidates)
                    .where(created_at: @since..)
                    .where("comments.user_id <> articles.user_id")
                    .group("comments.article_id", "comments.user_id")
                    .select("comments.article_id, comments.user_id, MAX(comments.created_at) AS last_at")
    Comment.unscoped.from(latest, :commenters)
           .group("commenters.article_id")
           .pluck(Arel.sql("commenters.article_id"), score(:comments), Arel.sql("COUNT(*)"))
  end

  def candidates
    Article.published.where.not(user_id: Article::RANKING_EXCLUDED_USER_ID)
  end

  def score(signal)
    binds = WEIGHTS.merge(now: @now.utc, half_life: HALF_LIFE_MINUTES)
    Arel.sql(ActiveRecord::Base.sanitize_sql_array([ScoreSql::FRAGMENTS.fetch(signal), binds]))
  end

  # The top MAX_RANKED in score order, with any one author kept to AUTHOR_CAP of them
  def diversify(ids)
    authors = Article.where(id: ids).pluck(:id, :user_id).to_h
    counts = Hash.new(0)
    ids.each_with_object([]) do |id, picked|
      break picked if picked.size == MAX_RANKED
      next if counts[authors[id]] >= AUTHOR_CAP

      counts[authors[id]] += 1
      picked << id
    end
  end

  def store(ranked, scores)
    Article.transaction do
      Article.where.not(trending_rank: nil).or(Article.where.not(trending_score: 0))
             .update_all(trending_rank: nil, trending_score: 0)
      ranked.each.with_index(1) do |id, rank|
        Article.where(id:).update_all(trending_rank: rank, trending_score: scores[id].round(4))
      end
    end
  end
end
