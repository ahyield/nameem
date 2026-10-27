# The list of pages search engines should know about, built on request and cached until an article changes
class SitemapsController < ApplicationController
  skip_before_action :require_authentication

  def show
    expires_in 1.hour, public: true
    render xml: Rails.cache.fetch(["sitemap", Article.published.maximum(:updated_at), Article.published.count, Tag.count]) {
      render_to_string(:show, formats: :xml)
    }
  end

  private

  helper_method :indexed_articles, :indexed_authors, :indexed_topics

  def indexed_articles
    Article.published.where(noindex: false, canonical_url: nil).includes(:user)
  end

  def indexed_authors
    User.where(id: Article.published.select(:user_id))
  end

  def indexed_topics
    Tag.where("articles_count > 0")
  end
end
