class CreateArticleLikes < ActiveRecord::Migration[8.2]
  def change
    create_table :article_likes do |t|
      t.references :article, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :article_likes, [:article_id, :user_id], unique: true
    add_column :articles, :likes_count, :integer, default: 0, null: false
  end
end
