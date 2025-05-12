class AddLastPlausibleSyncToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :plausible_last_synced_at, :datetime
  end
end
