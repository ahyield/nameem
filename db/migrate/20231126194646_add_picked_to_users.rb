class AddPickedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :picked, :boolean, default: false, null: false

    add_index :users, :picked
  end
end
