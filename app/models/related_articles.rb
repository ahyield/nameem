# "مقالات ذات صلة" under an article. Most articles have no topics, so relatedness comes from the text itself:
# MySQL's natural-language full-text match (fulltext_articles_search) on the article's own key words, plus a
# boost for shared topics and a little for engagement. Other writers only (the author has their own section),
# in the same language, topped up with what's trending when the text finds too little.
class RelatedArticles
  MAX_QUERY_WORDS = 30
  MIN_WORD_LENGTH = 3
  # Best text matches considered before re-ranking
  CANDIDATE_POOL = 20
  # A shared topic counts for more the rarer it is (a broad topic like «أدب» says little); engagement
  # only breaks near-ties
  TOPIC_WEIGHT = 1.5
  ENGAGEMENT_WEIGHT = 0.02
  # Common Arabic function words that say nothing about what an article is about
  STOPWORDS = %w[
    التي الذي الذين اللذين اللتين هذا هذه ذلك تلك هؤلاء أولئك هناك هنا كان كانت يكون تكون كانوا
    على إلى الى عن من في مع بين حتى عند لدى منذ خلال بعد قبل حول ضد نحو دون غير سوى إلا الا
    لكن لكنه لأن لان كما مثل أيضا ايضا أيضاً فقط جدا جداً كل بعض أي اي أو او أم ثم قد لقد لم لن لا ما ماذا
    متى أين اين كيف لماذا هل نعم إذا اذا إن ان أن إنه انه أنه إنها انها أنها وهو وهي هو هي هم هن نحن أنا انا
    أنت انت أنتم انتم كنت كنا يا وقد وما ولا وفي ومن وعلى والتي والذي فيه فيها منه منها عليه عليها إليه اليه
    به بها لها له لهم بهم عنه عنها كله كلها ذات ليس ليست شيء شي يمكن عندما بينما حيث لو كأن
  ].to_set.freeze

  def self.for(article, limit: 3)
    new(article, limit).articles
  end

  def initialize(article, limit)
    @article = article
    @limit = limit
  end

  def articles
    picked = by_text
    picked += fill(exclude: picked) if picked.size < @limit
    picked.first(@limit)
  end

  private

  # Other writers' published articles; matched by text only within the same language
  def candidates(same_language: true)
    scope = Article.published.where.not(id: @article.id).where.not(user_id: @article.user_id)
                   .includes(:user, images_attachments: :blob)
    same_language ? scope.where(mostly_latin: @article.mostly_latin) : scope
  end

  # Text relevance, normalised against the best match, plus TOPIC_WEIGHT per shared topic and a little
  # for engagement. Raw MATCH scores have no fixed scale, so they're compared within this article's matches.
  def by_text
    query = key_words.join(" ")
    return [] if query.blank?

    matches = candidates.select("articles.*", "#{match_sql(query)} AS relevance", "#{shared_topics_sql} AS shared_topics")
                        .where(Arel.sql("#{match_sql(query)} > 0"))
                        .order(Arel.sql("relevance DESC")).limit(CANDIDATE_POOL).to_a
    best = matches.first&.relevance.to_f
    matches.sort_by { |candidate| -score(candidate, best) }.first(@limit)
  end

  def score(candidate, best)
    engagement = (candidate.likes_count * 3) + (candidate.comments_count * 5) + candidate.real_views_count
    (candidate.relevance.to_f / best) + (candidate.shared_topics.to_f * TOPIC_WEIGHT) +
      (Math.log(1 + engagement) * ENGAGEMENT_WEIGHT)
  end

  def match_sql(query)
    ActiveRecord::Base.sanitize_sql_array(
      ["MATCH(articles.title, articles.description, articles.content_html) AGAINST(? IN NATURAL LANGUAGE MODE)", query]
    )
  end

  # Sum over shared topics of 1 / ln(2 + articles in that topic)
  def shared_topics_sql
    ActiveRecord::Base.sanitize_sql_array(
      ["(SELECT COALESCE(SUM(1 / LN(2 + tags.articles_count)), 0) FROM article_tags shared " \
       "INNER JOIN tags ON tags.id = shared.tag_id WHERE shared.article_id = articles.id AND shared.tag_id IN (?))",
       @article.tag_ids.presence || [0]]
    )
  end

  # When the text finds too little: what's trending, then the most engaging of the last two months.
  # Any language here, so a rare English article still gets suggestions.
  def fill(exclude:)
    ids = exclude.map(&:id)
    trending = candidates(same_language: false).trending.where.not(id: ids).limit(@limit).to_a
    ids += trending.map(&:id)
    recent = candidates(same_language: false).where(published_at: 60.days.ago..).where.not(id: ids)
                                             .order(Arel.sql("likes_count * 3 + comments_count * 5 + real_views_count DESC"))
                                             .limit(@limit).to_a
    trending + recent
  end

  # Words from the title, the description and the opening of the body, minus function words
  def key_words
    text = [@article.title, @article.description, body_opening].compact.join(" ")
    text.downcase.scan(/[[:alpha:]]+/)
        .reject { |word| word.length < MIN_WORD_LENGTH || STOPWORDS.include?(word) }
        .uniq.first(MAX_QUERY_WORDS)
  end

  def body_opening
    ActionController::Base.helpers.strip_tags(@article.content_html.to_s).squish.first(600)
  end
end
