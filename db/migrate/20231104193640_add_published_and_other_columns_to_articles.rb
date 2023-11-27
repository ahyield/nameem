class AddPublishedAndOtherColumnsToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :featured, :boolean, default: false, null: false
    add_column :articles, :published, :boolean, default: false, null: false
    add_column :articles, :picked, :boolean, default: false, null: false

    add_index :articles, :featured
    add_index :articles, :picked
    add_index :articles, :published
    add_index :articles, :published_at
  end
end
