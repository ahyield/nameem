module Metable
  extend ActiveSupport::Concern

  SUMMARY_LENGTH = 155
  SUMMARY_BLOCKS = "p, h1, h2, h3, blockquote, li, pre, figcaption, div".freeze

  included do
    # Derived fields are set before saving, so an autosave writes one UPDATE
    before_save :refresh_content_metadata, if: :content_html_changed?
    before_save :detect_language, if: -> { title_changed? || content_html_changed? }

    def detect_language
      self.mostly_latin = ArticleLanguage.mostly_latin?(title, content_html)
    end

    def refresh_content_metadata
      return if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      words = doc.text.split(/\s+/).count { |w| w.length > 1 }
      self.reading_time_minutes = [(words / 200.0).ceil, 1].max

      summary = content_summary(doc)
      self.description = summary if summary.present? && description_follows_content?
    end

    # The description tracks the content until the author writes their own
    def description_follows_content?
      return false if description_changed? && description.present?

      previous = Nokogiri::HTML.fragment(content_html_was.to_s)
      description.blank? || description.in?([content_summary(previous), legacy_content_summary(previous)])
    end

    # The opening of the article as search engines show it: about 155 characters, cut at a word, with a
    # space between paragraphs so their sentences don't run together
    def content_summary(doc)
      doc = doc.dup
      doc.css(SUMMARY_BLOCKS).each { |block| block.add_next_sibling(" ") }
      doc.text.squish.truncate(SUMMARY_LENGTH, separator: " ", omission: "…").presence
    end

    # Descriptions written before summaries were longer; they still count as following the content
    def legacy_content_summary(doc)
      doc.text.squish.truncate(100).presence
    end

    def alternative_titles(html = content_html)
      return [] if html.blank?

      doc = Nokogiri::HTML.fragment(html)
      doc.css("h1, h2, p").map { |el| el.text.strip }.select { |t| t.length >= 5 }
    end

    def article_images
      return [] if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      doc.css("img").filter_map { |img| img["src"] }
    end
  end
end
