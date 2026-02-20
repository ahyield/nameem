class AddFulltextIndexToArticles < ActiveRecord::Migration[8.2]
  def change
    add_index :articles, [:title, :description, :content_html], type: :fulltext, name: "fulltext_articles_search"
  end
end
