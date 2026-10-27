# What an author can set in the publish dialog's advanced section: a title for search results, the cover used
# when the article is shared, where the original lives (when it was first published elsewhere), and whether
# search engines should list it at all
module SeoSettings
  extend ActiveSupport::Concern

  SEO_TITLE_LENGTH = 70
  SLUG_FORMAT = /\A[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*\z/

  included do
    normalizes :seo_title, :canonical_url, with: ->(value) { value.strip.presence }

    validates :seo_title, length: { maximum: SEO_TITLE_LENGTH }
    validates :slug, format: { with: SLUG_FORMAT }, length: { maximum: 80 }, allow_nil: true
    validate :canonical_url_points_elsewhere, if: -> { canonical_url.present? }
    validate :cover_is_in_the_article, if: -> { cover_image_src.present? && cover_image_src_changed? }

    # A chosen cover that was taken out of the article stops being the cover
    before_save :drop_missing_cover, if: -> { cover_image_src.present? && content_html_changed? }
  end

  # The image the article is shown with in cards and link previews: the chosen one, or the first
  def cover_image
    cover_image_src.presence_in(article_images) || article_images.first
  end

  private

  def canonical_url_points_elsewhere
    uri = URI.parse(canonical_url)
    errors.add(:canonical_url, :invalid) unless uri.is_a?(URI::HTTPS) && uri.host.present? && !uri.host.end_with?("nameem.com")
  rescue URI::InvalidURIError
    errors.add(:canonical_url, :invalid)
  end

  def cover_is_in_the_article
    errors.add(:cover_image_src, :inclusion) unless cover_image_src.in?(article_images)
  end

  def drop_missing_cover
    self.cover_image_src = nil unless cover_image_src.in?(article_images)
  end
end
