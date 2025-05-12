class UpdateArticleViewsJob < ApplicationJob
  queue_as :default

  SYNC_THRESHOLD = 6.hours

  def perform
    Article.published
           .order("plausible_last_synced_at ASC NULLS FIRST")
           .find_each(batch_size: 100) do |article|
      process_article(article)
    end
  end

  private

  def process_article(article)
    # Skip if synced too recently
    if recently_synced?(article)
      log_skipping_article(article)
      return
    end

    begin
      update_article_stats(article)
    rescue StandardError => e
      log_error(article, e)
    end
  end

  def recently_synced?(article)
    article.plausible_last_synced_at && article.plausible_last_synced_at > SYNC_THRESHOLD.ago
  end

  def log_skipping_article(article)
    hours = (SYNC_THRESHOLD / 1.hour).to_i
    Rails.logger.info "Article #{article.id} already synced within the last #{hours} hours, skipping update."
  end

  def update_article_stats(article)
    stats = PlausibleClient::Plausible.new(article: article).aggregate
    views_count, visitors_count = stats.values_at(:pageviews, :visitors).map(&:to_i)

    if views_count.zero? && visitors_count.zero?
      handle_no_stats(article)
      return
    end

    article.update(
      page_views:               views_count,
      visitors:                 visitors_count,
      plausible_last_synced_at: Time.current
    )

    Rails.logger.info "Updated article #{article.id} with #{views_count} views, #{visitors_count} visitors"
  end

  def handle_no_stats(article)
    Rails.logger.info "Article #{article.id} not found in Plausible, skipping update."
    # Still update the sync timestamp to avoid repeatedly checking articles with no stats
    article.update(plausible_last_synced_at: Time.current)
  end

  def log_error(article, exception)
    Rails.logger.error "Error updating article #{article.id}: #{exception.message}"
    # Log to sentry
    Sentry.capture_exception(exception, extra: { article_id: article.id })
  end
end
