class CleanupStaleMagicLinksJob < ApplicationJob
  queue_as :default

  def perform
    MagicLink.stale.delete_all
  end
end
