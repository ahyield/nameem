module JsonLdHelper
  def json_ld_tag(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def article_json_ld(article, user)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => article.title,
      "description" => article.description&.truncate(160),
      "datePublished" => (article.published_at || article.created_at).iso8601,
      "dateModified" => article.updated_at.iso8601,
      "url" => user_article_url(slug: user, uuid: article),
      "author" => {
        "@type" => "Person",
        "name" => user.name,
        "url" => user_url(slug: user.slug)
      },
      "publisher" => {
        "@type" => "Organization",
        "name" => "نميم",
        "logo" => {
          "@type" => "ImageObject",
          "url" => asset_url("brand/logo.png")
        }
      }
    }

    cover = article_cover(article)
    data["image"] = cover if cover.present?

    data
  end

  def profile_json_ld(user)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Person",
      "name" => user.name,
      "url" => user_url(slug: user.slug)
    }

    data["description"] = user.bio if user.bio.present?
    data["image"] = rails_blob_url(user.avatar) if user.avatar.attached?

    data
  end
end
