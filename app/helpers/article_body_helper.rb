module ArticleBodyHelper
  include CoverImageHelper

  ARTICLE_TAGS = %w[p h1 h2 h3 blockquote a img iframe figure figcaption hr div span br strong em u s code pre].freeze
  ARTICLE_ATTRIBUTES = %w[href src class data-tweet-id frameborder allowfullscreen alt title dir style target rel width
                          height].freeze
  IMAGE_LIMIT = [1600, 1600].freeze
  BACKDROP_SIZE = [48, 48].freeze
  # Images narrower than this (width / height) would shrink to a strip under the height cap, so they get a
  # full-width frame filled with a blurred copy of themselves
  FRAME_BELOW_RATIO = 1.2

  # The article's HTML, sanitized, with its uploaded images served at a reading size (the original kept for the
  # image viewer) and sized up front so the page doesn't jump as they load. Cached until the article changes.
  def article_body(article)
    Rails.cache.fetch([article, article.updated_at.to_f, "article_body/v3"]) do
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
    size(img, blob)
  end

  # Sets the reading-size dimensions up front, and frames tall photos. Editor uploads are never attached to a
  # record, so Active Storage doesn't analyze them; read their size once here (the result is stored, and the
  # article's HTML is cached).
  def size(img, blob)
    analyze(blob)
    width, height = blob.metadata.values_at("width", "height")
    return unless width && height

    scale = [IMAGE_LIMIT.first / width.to_f, IMAGE_LIMIT.last / height.to_f, 1].min
    img["width"] = (width * scale).round
    img["height"] = (height * scale).round
    frame(img, blob) if width.to_f / height < FRAME_BELOW_RATIO
  end

  def analyze(blob)
    blob.analyze unless blob.analyzed?
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  def frame(img, blob)
    backdrop = rails_representation_url(blob.variant(resize_to_limit: BACKDROP_SIZE))
    wrapper = img.document.create_element("span", class: "image-frame", style: "--image-backdrop: url('#{backdrop}')")
    img.replace(wrapper)
    wrapper.add_child(img)
  end
end
