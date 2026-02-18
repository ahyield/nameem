class CreateMagicLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_links do |t|
      t.references :user, foreign_key: true
      t.string :code, null: false
      t.integer :purpose, null: false, default: 0
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :magic_links, :code, unique: true
    add_index :magic_links, :expires_at
  end
end
