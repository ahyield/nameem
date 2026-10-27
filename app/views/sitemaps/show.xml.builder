xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset :xmlns        => "http://www.sitemaps.org/schemas/sitemap/0.9",
           "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1" do
  xml.url { xml.loc root_url }
  xml.url { xml.loc topics_url }
  xml.url { xml.loc about_nameem_url }

  indexed_articles.find_each do |article|
    xml.url do
      xml.loc article_link_url(article)
      xml.lastmod article.updated_at.iso8601
      image = cover_image_url(article, ArticleSeoHelper::SHARE_IMAGE_SIZE) || article_cover(article)
      xml.tag!("image:image") { xml.tag!("image:loc", image) } if image
    end
  end

  indexed_authors.find_each do |user|
    xml.url do
      xml.loc user_url(slug: user.slug)
      xml.lastmod user.updated_at.iso8601
    end
  end

  indexed_topics.find_each do |tag|
    xml.url do
      xml.loc topic_url(tag)
      xml.lastmod tag.updated_at.iso8601
    end
  end
end
