SitemapGenerator::Sitemap.default_host = "https://nameem.com"

SitemapGenerator::Sitemap.create do
  # Static pages
  add "/topics", changefreq: "daily"
  add "/about-nameem", changefreq: "monthly"

  # Published articles
  Article.published.find_each do |article|
    add "/#{article.user.slug}/#{article.uuid}",
      lastmod: article.updated_at,
      changefreq: "weekly"
  end

  # User profiles (only those with published articles)
  User.joins(:articles).merge(Article.published).distinct.find_each do |user|
    add "/#{user.slug}",
      lastmod: user.updated_at,
      changefreq: "weekly"
  end

  # Topics with articles
  Tag.where("articles_count > 0").find_each do |tag|
    add "/topics/#{tag.slug}",
      lastmod: tag.updated_at,
      changefreq: "weekly"
  end
end
