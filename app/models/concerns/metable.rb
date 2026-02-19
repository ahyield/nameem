module Metable
  extend ActiveSupport::Concern

  included do
    after_update :update_description, :update_reading_time

    def update_description
      return if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      text = doc.text.squish
      update_column(:description, text.truncate(100)) if text.present?
    end

    def update_reading_time
      return if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      words = doc.text.split(/\s+/).count { |w| w.length > 1 }
      minutes = [ (words / 200.0).ceil, 1 ].max
      update_column(:reading_time_minutes, minutes)
    end

    def alternative_titles
      return [] if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      doc.css("h1, h2, p").map { |el| el.text.strip }.select { |t| t.length >= 5 }
    end

    def article_images
      return [] if content_html.blank?

      doc = Nokogiri::HTML.fragment(content_html)
      doc.css("img").filter_map { |img| img["src"] }
    end
  end
end
