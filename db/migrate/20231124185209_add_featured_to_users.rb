class AddFeaturedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :featured, :boolean

    add_index :users, :featured
  end
end
