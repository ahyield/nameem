class UpdateArticleViewsJob < ApplicationJob
  queue_as :default

  def perform
    Article.find_each do |article|
      next unless article.published?

      stats = PlausibleClient::Plausible.new(article: article).aggregate
      views_count, visitors_count = stats.values_at("pageviews", "visitors").map(&:to_i)

      if views_count.zero? && visitors_count.zero?
        Rails.logger.info "Article #{article.id} not found in Plausible, skipping update."
        next
      end

      # Update the article with the new page views and visitors
      article.update(
        views_count:    page_views,
        visitors_count: visitors
      )
    end
  end
end
