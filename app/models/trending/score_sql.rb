class Trending
  # Decayed score per signal: weight × 0.5 ^ (minutes since the event ÷ half-life). Trending#score fills in
  # the weights, time and half-life with sanitize_sql_array, so the only SQL here is these constants.
  module ScoreSql
    DECAY = "POW(0.5, TIMESTAMPDIFF(MINUTE, %<at>s, :now) / :half_life)".freeze
    FRAGMENTS = {
      views:     "SUM(:open * #{format(DECAY, at: 'page_views.created_at')} + CASE WHEN page_views.read_at IS NULL " \
                 "THEN 0 ELSE :read * #{format(DECAY, at: 'page_views.read_at')} END)",
      likes:     "SUM(:like * #{format(DECAY, at: 'article_likes.created_at')})",
      bookmarks: "SUM(:save * #{format(DECAY, at: 'bookmarks.created_at')})",
      comments:  "SUM(:comment * #{format(DECAY, at: 'commenters.last_at')})"
    }.freeze
  end
end
