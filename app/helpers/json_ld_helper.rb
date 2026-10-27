module JsonLdHelper
  include ArticleSeoHelper

  def json_ld_tag(data)
    # JSON inside <script> must not be HTML-escaped, so it's marked safe after json_escape
    # turns <, > and & into \u escapes; a title like "</script>" can't break out of the tag.
    tag.script(json_escape(data.to_json).html_safe, type: "application/ld+json") # rubocop:disable Rails/OutputSafety
  end

  def article_json_ld(article, user)
    url = article_link_url(article)
    data = {
      "@context"         => "https://schema.org",
      "@type"            => "Article",
      "headline"         => article_seo_title(article),
      "description"      => article_seo_description(article),
      "datePublished"    => (article.published_at || article.created_at).iso8601,
      "dateModified"     => article.updated_at.iso8601,
      "url"              => url,
      "mainEntityOfPage" => { "@type" => "WebPage", "@id" => url },
      "inLanguage"       => article_language(article),
      "wordCount"        => article_word_count(article),
      "author"           => {
        "@type" => "Person",
        "name"  => user.name,
        "url"   => user_url(slug: user.slug)
      },
      "publisher"        => {
        "@type" => "Organization",
        "name"  => "نميم",
        "logo"  => {
          "@type" => "ImageObject",
          "url"   => asset_url("brand/logo.png")
        }
      }
    }

    data.merge(article_topics_json_ld(article), article_images_json_ld(article))
  end

  # نميم › author › article, shown by search engines in place of the bare address
  def article_breadcrumb_json_ld(article, user)
    crumbs = [["نميم", root_url], [user.name, user_url(slug: user.slug)], [article_seo_title(article), article_link_url(article)]]

    {
      "@context"        => "https://schema.org",
      "@type"           => "BreadcrumbList",
      "itemListElement" => crumbs.each_with_index.map do |(name, item), index|
        { "@type" => "ListItem", "position" => index + 1, "name" => name, "item" => item }
      end
    }
  end

  # The home page as a site that can be searched from the results page
  def website_json_ld
    {
      "@context"        => "https://schema.org",
      "@type"           => "WebSite",
      "name"            => "نميم",
      "url"             => root_url,
      "inLanguage"      => "ar",
      "potentialAction" => {
        "@type"       => "SearchAction",
        "target"      => "#{search_url}?q={search_term_string}",
        "query-input" => "required name=search_term_string"
      }
    }
  end

  def topic_json_ld(tag)
    {
      "@context"    => "https://schema.org",
      "@type"       => "CollectionPage",
      "name"        => tag.name,
      "description" => "مقالات عن #{tag.name} على نميم",
      "url"         => topic_url(tag),
      "inLanguage"  => "ar"
    }
  end

  def profile_json_ld(user)
    data = {
      "@context" => "https://schema.org",
      "@type"    => "Person",
      "name"     => user.name,
      "url"      => user_url(slug: user.slug)
    }

    data["description"] = user.bio if user.bio.present?
    data["image"] = rails_blob_url(user.avatar) if user.avatar.attached?
    profiles = [user.website_link, *User::SOCIAL_HANDLES.map { |handle| user.social_link(handle) }].compact
    data["sameAs"] = profiles if profiles.any?

    data
  end

  private

  def article_topics_json_ld(article)
    topics = article.tags.map(&:name)
    topics.any? ? { "keywords" => topics.join("، "), "articleSection" => topics.first } : {}
  end

  # The cover in the shapes search results use, wide and square
  def article_images_json_ld(article)
    images = [cover_image_url(article, SHARE_IMAGE_SIZE), cover_image_url(article, [1200, 1200])].compact
    images = [article_cover(article)].compact if images.empty?
    images.any? ? { "image" => images } : {}
  end

  def article_word_count(article)
    Nokogiri::HTML5.fragment(article.content_html.to_s).text.split(/\s+/).count(&:present?)
  end
end
