# Every 15 minutes (config/schedule.yml): recompute the الرائج ranking
class RefreshTrendingJob < ApplicationJob
  queue_as :default

  def perform
    Trending.compute!
  end
end
