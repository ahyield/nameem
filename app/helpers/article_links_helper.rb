# Where an article is read: its readable permalink. Likes, comments and editing keep using the UUID.
module ArticleLinksHelper
  def article_link(article)
    user_article_path(slug: article.user, uuid: article.permalink_param)
  end

  def article_link_url(article)
    user_article_url(slug: article.user, uuid: article.permalink_param)
  end
end
