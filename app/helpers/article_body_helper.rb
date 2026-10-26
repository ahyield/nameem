module ArticleBodyHelper
  include CoverImageHelper

  ARTICLE_TAGS = %w[p h1 h2 h3 blockquote a img iframe figure figcaption hr div span br strong em u s code pre].freeze
  ARTICLE_ATTRIBUTES = %w[href src class data-tweet-id frameborder allowfullscreen alt title dir style target rel width
                          height].freeze
  IMAGE_LIMIT = [1600, 1600].freeze

  # The article's HTML, sanitized, with its uploaded images served at a reading size (the original kept for the
  # image viewer) and sized up front so the page doesn't jump as they load. Cached until the article changes.
  def article_body(article)
    Rails.cache.fetch([article, article.updated_at.to_f, "article_body/v1"]) do
      html = sanitize(article.content_html, tags: ARTICLE_TAGS, attributes: ARTICLE_ATTRIBUTES).to_s
      fragment = Nokogiri::HTML5.fragment(html)
      fragment.css("img").each_with_index { |img, index| prepare_image(img, lazy: index.positive?) }
      fragment.to_html
    end.html_safe # rubocop:disable Rails/OutputSafety -- sanitized above; we only rewrote img attributes
  end

  private

  def prepare_image(img, lazy:)
    if lazy
      img["loading"] = "lazy"
      img["decoding"] = "async"
    end
    img.remove_attribute("class")

    blob = blob_from_url(img["src"])
    return unless blob&.variable?

    img["data-full-src"] = img["src"]
    img["src"] = rails_representation_url(blob.variant(resize_to_limit: IMAGE_LIMIT))
    width, height = blob.metadata.values_at("width", "height")
    return unless width && height

    scale = [IMAGE_LIMIT.first / width.to_f, IMAGE_LIMIT.last / height.to_f, 1].min
    img["width"] = (width * scale).round
    img["height"] = (height * scale).round
  end
end
