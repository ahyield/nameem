class AddConfirmationToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirmed, :boolean
  end
end
