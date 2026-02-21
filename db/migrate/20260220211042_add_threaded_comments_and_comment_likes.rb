class AddThreadedCommentsAndCommentLikes < ActiveRecord::Migration[8.2]
  def change
    add_reference :comments, :parent, foreign_key: { to_table: :comments }, null: true
    add_reference :comments, :mentioned_user, foreign_key: { to_table: :users }, null: true
    add_column :comments, :replies_count, :integer, default: 0, null: false
    add_column :comments, :likes_count, :integer, default: 0, null: false

    create_table :comment_likes do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :comment_likes, [:user_id, :comment_id], unique: true
  end
end
