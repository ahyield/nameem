class CreateComments < ActiveRecord::Migration[8.2]
  def change
    create_table :comments do |t|
      t.references :article, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_column :articles, :comments_count, :integer, default: 0, null: false
  end
end
