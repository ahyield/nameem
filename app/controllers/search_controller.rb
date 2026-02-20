class SearchController < ApplicationController
  include ArabicSearchable

  skip_before_action :require_authentication
  before_action :resume_session

  NORMALIZE_SQL = "REPLACE(REPLACE(REPLACE(%s, 'أ', 'ا'), 'إ', 'ا'), 'آ', 'ا')"

  def index
    @query = params[:q].to_s.strip
    if @query.present?
      normalized = self.class.normalize_arabic(@query)
      sanitized = Article.sanitize_sql_like(normalized)
      ft_query = normalized.split.map { |w| "+#{w}*" }.join(" ")

      title_norm = format(NORMALIZE_SQL, "title")
      desc_norm = format(NORMALIZE_SQL, "description")
      body_norm = format(NORMALIZE_SQL, "content_html")
      quoted_like = Article.connection.quote("%#{sanitized}%")
      ft_score = "MATCH(title, description, content_html) AGAINST(#{Article.connection.quote(ft_query)} IN BOOLEAN MODE)"
      rank = "((#{title_norm} LIKE #{quoted_like}) * 10 + (#{desc_norm} LIKE #{quoted_like}) * 5 + #{ft_score})"

      @pagy, @articles = pagy(
        Article.published
               .includes(:user, :tags)
               .where(
                 "MATCH(title, description, content_html) AGAINST(:ft IN BOOLEAN MODE) OR #{title_norm} LIKE :like OR #{desc_norm} LIKE :like OR #{body_norm} LIKE :like",
                 ft: ft_query, like: "%#{sanitized}%"
               )
               .order(Arel.sql("#{rank} DESC")),
        limit: 10
      )

      name_norm = format(NORMALIZE_SQL, "CONCAT(first_name, ' ', last_name)")
      @users = User.confirmed
                   .where("#{name_norm} LIKE ?", "%#{sanitized}%")
                   .limit(10)

      tag_norm = format(NORMALIZE_SQL, "name")
      @tags = Tag.with_articles
                 .where("#{tag_norm} LIKE ?", "%#{sanitized}%")
                 .order(articles_count: :desc)
                 .limit(10)
    else
      @pagy = nil
      @articles = Article.none
      @users = User.none
      @tags = Tag.none
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def autocomplete
    query = params[:q].to_s.strip
    if query.blank?
      return render json: { people: [], articles: [], topics: [] }
    end

    normalized = self.class.normalize_arabic(query)
    sanitized = Article.sanitize_sql_like(normalized)
    ft_query = normalized.split.map { |w| "+#{w}*" }.join(" ")

    title_norm = format(NORMALIZE_SQL, "title")
    desc_norm = format(NORMALIZE_SQL, "description")
    body_norm = format(NORMALIZE_SQL, "content_html")
    quoted_like = Article.connection.quote("%#{sanitized}%")
    ft_score = "MATCH(title, description, content_html) AGAINST(#{Article.connection.quote(ft_query)} IN BOOLEAN MODE)"
    rank = "((#{title_norm} LIKE #{quoted_like}) * 10 + (#{desc_norm} LIKE #{quoted_like}) * 5 + #{ft_score})"

    articles = Article.published
                      .includes(:user)
                      .where(
                        "MATCH(title, description, content_html) AGAINST(:ft IN BOOLEAN MODE) OR #{title_norm} LIKE :like OR #{desc_norm} LIKE :like OR #{body_norm} LIKE :like",
                        ft: ft_query, like: "%#{sanitized}%"
                      )
                      .order(Arel.sql("#{rank} DESC"))
                      .limit(3)

    name_norm = format(NORMALIZE_SQL, "CONCAT(first_name, ' ', last_name)")
    people = User.confirmed
                 .where("#{name_norm} LIKE ?", "%#{sanitized}%")
                 .limit(3)

    tag_norm = format(NORMALIZE_SQL, "name")
    topics = Tag.with_articles
                .where("#{tag_norm} LIKE ?", "%#{sanitized}%")
                .order(articles_count: :desc)
                .limit(3)

    render json: {
      people:   people.map { |u| { name: u.name, slug: u.slug, avatar_url: avatar_url(u) } },
      articles: articles.map { |a| { title: a.title, uuid: a.uuid, slug: a.user.slug, cover_url: article_cover_url(a) } },
      topics:   topics.map { |t| { name: t.name, slug: t.slug } }
    }
  end

  private

  def avatar_url(user)
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
    end
  end

  def article_cover_url(article)
    images = article.article_images
    if images.any?
      images.first
    end
  end
end
