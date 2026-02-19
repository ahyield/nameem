class CreateTagsAndArticleTags < ActiveRecord::Migration[8.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :articles_count, default: 0, null: false
      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true

    create_table :article_tags do |t|
      t.references :article, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end

    add_index :article_tags, [:article_id, :tag_id], unique: true
  end
end
