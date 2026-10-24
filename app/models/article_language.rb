# Tells mostly-English articles apart from Arabic ones, which may use English terms. Nameem is Arabic first,
# so English articles get less presence in الرائج (see Trending and Article.newcomers).
module ArticleLanguage
  ARABIC = /[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]/
  LATIN = /[A-Za-z]/
  URL = %r{https?://\S+|www\.\S+|\S+@\S+\.\S+}
  # Fewer Latin letters than this is a title or a few words, not an English article
  MIN_LATIN_LETTERS = 50

  module_function

  # More than half of the letters are Latin, ignoring code, links and numbers
  def mostly_latin?(title, content_html)
    text = "#{title} #{readable_text(content_html)}".gsub(URL, " ")
    latin = text.scan(LATIN).size
    latin >= MIN_LATIN_LETTERS && latin > text.scan(ARABIC).size
  end

  def readable_text(html)
    return "" if html.blank?

    doc = Nokogiri::HTML.fragment(html)
    doc.css("pre, code, script, style").each(&:remove)
    doc.text
  end
end
