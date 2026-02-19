desc "Backfill reading_time_minutes for all articles"
task backfill_reading_time: :environment do
  Article.where(reading_time_minutes: nil).where.not(content_html: nil).find_each do |article|
    doc = Nokogiri::HTML.fragment(article.content_html)
    words = doc.text.split(/\s+/).count { |w| w.length > 1 }
    minutes = [ (words / 200.0).ceil, 1 ].max
    article.update_column(:reading_time_minutes, minutes)
    print "."
  end
  puts "\nDone."
end

desc "Migrate Quill Delta content to HTML"
task migrate_quill_to_html: :environment do
  require "cgi"

  Article.where(content_html: nil).where.not(content: nil).find_each do |article|
    ops = article.content.is_a?(Hash) ? article.content["ops"] : nil
    next print("s") unless ops.is_a?(Array) && ops.any?

    html = DeltaConverter.convert(ops)
    if html.present?
      article.update_column(:content_html, html)
      print "."
    else
      print "x"
    end
  end
  puts "\nDone."
end

# Converts Quill Delta ops to HTML. One-time migration utility.
module DeltaConverter
  module_function

  def convert(ops)
    html = +""
    buffer = +""

    ops.each do |op|
      insert = op["insert"]
      attrs = op["attributes"] || {}

      if insert.is_a?(Hash)
        html << buffer if buffer.present?
        buffer = +""
        html << render_embed(insert)
        next
      end

      process_text(insert.to_s, attrs, html, buffer).then { |b| buffer = b }
    end

    html << "<p>#{buffer}</p>" if buffer.present?
    html
  end

  def process_text(text, attrs, html, buffer)
    lines = text.split("\n", -1)

    lines.each_with_index do |line, idx|
      buffer << apply_inline(line, attrs) if line.present?
      next unless idx < lines.length - 1

      html << flush_block(buffer, attrs)
      buffer = +""
    end

    buffer
  end

  def render_embed(insert)
    return render_image(insert) if insert["customImage"] || insert["image"]
    return %(<div class="tweet-embed" data-tweet-id="#{esc(insert['tweet'])}"></div>) if insert["tweet"]
    return %(<hr class="editor-hr">) if insert["divider"]
    return render_video(insert["video"]) if insert["video"]

    ""
  end

  def render_image(insert)
    url = insert["customImage"] || insert["image"]
    url = url["url"] if url.is_a?(Hash)
    %(<figure><img src="#{esc(url)}" class="py-4"></figure>)
  end

  def render_video(src)
    %(<figure><iframe src="#{esc(src)}" frameborder="0" allowfullscreen width="740" height="360"></iframe></figure>)
  end

  def flush_block(content, attrs)
    return "<h#{attrs['header']}>#{content}</h#{attrs['header']}>" if attrs["header"]
    return "<blockquote>#{content}</blockquote>" if attrs["blockquote"]
    return "<li>#{content}</li>" if attrs["list"]

    "<p>#{content.presence || '<br>'}</p>"
  end

  def apply_inline(text, attrs)
    result = esc(text)
    result = wrap_inline(result, attrs)
    result = %(<a href="#{esc(attrs['link'])}" target="_blank" rel="noopener">#{result}</a>) if attrs["link"]
    result
  end

  def wrap_inline(result, attrs)
    result = "<strong>#{result}</strong>" if attrs["bold"]
    result = "<em>#{result}</em>" if attrs["italic"]
    result = "<u>#{result}</u>" if attrs["underline"]
    result = "<s>#{result}</s>" if attrs["strike"]
    result = "<code>#{result}</code>" if attrs["code"]
    result
  end

  def esc(str)
    CGI.escapeHTML(str.to_s)
  end
end
