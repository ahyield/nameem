class CreateBookmarks < ActiveRecord::Migration[8.2]
  def change
    create_table :bookmarks do |t|
      t.references :article, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :bookmarks, [:article_id, :user_id], unique: true
  end
end
