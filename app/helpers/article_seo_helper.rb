# What search engines and link previews see for an article
module ArticleSeoHelper
  include ArticleLinksHelper
  include CoverImageHelper

  SHARE_IMAGE_SIZE = [1200, 630].freeze
  DESCRIPTION_LIMIT = 160

  def article_seo_title(article)
    article.title.presence || article.alternative_titles.first&.truncate(60)
  end

  def article_seo_description(article)
    article.description&.truncate(DESCRIPTION_LIMIT, separator: " ", omission: "…")
  end

  # The cover cropped to the size link previews use, or the site's own card when there's no photo
  def article_share_image(article)
    cropped = cover_image_url(article, SHARE_IMAGE_SIZE)
    return { url: cropped, width: SHARE_IMAGE_SIZE.first, height: SHARE_IMAGE_SIZE.last } if cropped

    { url: article_cover(article) || asset_url("brand/og-default.png") }
  end

  def article_language(article)
    article.mostly_latin? ? "en" : "ar"
  end

  def article_meta_tags(article, user)
    title = article_seo_title(article)
    description = article_seo_description(article)
    image = article_share_image(article)

    set_meta_tags title:       "#{title} بقلم #{user.name}",
                  description:,
                  canonical:   article_link_url(article),
                  og:          { type: "article", title:, description:, url: article_link_url(article),
                        image: { _: image[:url], width: image[:width], height: image[:height], alt: title }.compact },
                  article:     { published_time: article.published_at&.iso8601, modified_time: article.updated_at.iso8601,
                             author: user_url(slug: user.slug), tag: article.tags.map(&:name) },
                  twitter:     { title:, description:, image: image[:url] }
  end
end
