class AddUuidIndexToArticles < ActiveRecord::Migration[7.1]
  def change
    add_index :articles, :uuid, unique: true
  end
end
