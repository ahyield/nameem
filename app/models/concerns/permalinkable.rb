# Readable article URLs: /author/words-from-the-title-01bc2c65. The words come from the title and are only
# there for people and search engines; the article is found by the 8 hex characters at the end (the start of
# its UUID), so a changed slug or an old /author/<uuid> link can be redirected to the current one.
module Permalinkable
  extend ActiveSupport::Concern

  SHORT_ID_LENGTH = 8
  SLUG_LENGTH = 60
  # Arabic short vowels and other marks, and the tatweel used to stretch words
  ARABIC_MARKS = /[ؐ-ًؚ-ٰٟۖ-ۭـ]/
  PERMALINK = /\A(?:(?<slug>.+)-)?(?<short_id>[0-9a-f]{#{SHORT_ID_LENGTH}})\z/

  included do
    # The slug follows the title while the article is a draft, until the author writes their own; it stays put
    # once the article is published
    before_save :refresh_slug, if: :slug_follows_title?
  end

  class_methods do
    def slug_from(text)
      words = text.to_s.unicode_normalize(:nfkc).gsub(ARABIC_MARKS, "").downcase
                  .gsub(/[^\p{L}\p{N}]+/, "-").delete_prefix("-").delete_suffix("-")
      return if words.blank?
      return words if words.length <= SLUG_LENGTH

      cut = words[0, SLUG_LENGTH + 1]
      (cut.rindex("-") ? cut[0, cut.rindex("-")] : words[0, SLUG_LENGTH]).presence
    end

    # The article a permalink (or a full UUID) points to, or nil
    def at_link(param)
      return find_by(uuid: param) if param.to_s.match?(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)

      match = PERMALINK.match(param.to_s)
      return unless match

      short_id = match[:short_id]
      candidates = where("uuid BETWEEN UNHEX(?) AND UNHEX(?)", short_id.ljust(32, "0"), short_id.ljust(32, "f"))
      candidates.detect { |article| article.permalink_slug == match[:slug] } || candidates.first
    end
  end

  def permalink_param
    [permalink_slug, short_id].compact.join("-")
  end

  # Articles saved before slugs existed get one from their title until they're next saved
  def permalink_slug
    slug.presence || self.class.slug_from(slug_source)
  end

  def short_id
    uuid.to_s.delete("-").first(SHORT_ID_LENGTH)
  end

  private

  def slug_follows_title?
    return false if slug_changed? && slug.present?
    return true if slug.blank?

    !published_in_database && slug == self.class.slug_from(title_in_database.presence ||
                                                           alternative_titles(content_html_in_database).first)
  end

  def refresh_slug
    self.slug = self.class.slug_from(slug_source)
  end

  def slug_source
    title.presence || alternative_titles.first
  end
end
