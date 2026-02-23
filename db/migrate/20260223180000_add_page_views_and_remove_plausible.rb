class AddPageViewsAndRemovePlausible < ActiveRecord::Migration[8.2]
  def change
    create_table :page_views do |t|
      t.string :viewable_type, null: false
      t.bigint :viewable_id, null: false
      t.string :visitor_id, null: false
      t.timestamps
    end

    add_index :page_views, [:viewable_type, :viewable_id, :visitor_id], unique: true, name: "index_page_views_uniqueness"
    add_index :page_views, [:viewable_type, :viewable_id]

    add_column :articles, :real_views_count, :integer, default: 0, null: false
    add_column :users, :real_views_count, :integer, default: 0, null: false

    remove_column :articles, :views_count, :integer
    remove_column :articles, :visitors_count, :integer
    remove_column :articles, :plausible_last_synced_at, :datetime
  end
end
