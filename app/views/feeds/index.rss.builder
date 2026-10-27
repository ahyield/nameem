xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title @title
    xml.link @link
    xml.description "جرح طفيف في ذراع الحاضر العبثي"
    xml.language "ar"
    xml.tag!("atom:link", href: request.original_url, rel: "self", type: "application/rss+xml")

    @articles.each do |article|
      xml.item do
        xml.title article_seo_title(article)
        xml.link article_link_url(article)
        xml.guid article_link_url(article), isPermaLink: "true"
        xml.pubDate article.published_at&.rfc2822
        xml.author article.user.name
        xml.description article_seo_description(article)
      end
    end
  end
end
