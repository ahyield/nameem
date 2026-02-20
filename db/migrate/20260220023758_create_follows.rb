class CreateFollows < ActiveRecord::Migration[8.2]
  def change
    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :follows, [:follower_id, :followable_type, :followable_id], unique: true
    add_column :users, :followers_count, :integer, default: 0, null: false
    add_column :users, :following_count, :integer, default: 0, null: false
    add_column :tags, :followers_count, :integer, default: 0, null: false
  end
end
