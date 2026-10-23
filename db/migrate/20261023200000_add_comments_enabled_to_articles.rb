class AddCommentsEnabledToArticles < ActiveRecord::Migration[8.2]
  def change
    add_column :articles, :comments_enabled, :boolean, default: true, null: false
  end
end
