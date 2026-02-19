class AddContentHtmlToArticles < ActiveRecord::Migration[8.2]
  def change
    add_column :articles, :content_html, :mediumtext
  end
end
