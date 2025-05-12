class AddNumberOfViewsToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :views_count,    :integer
    add_column :articles, :visitors_count, :integer
  end
end
