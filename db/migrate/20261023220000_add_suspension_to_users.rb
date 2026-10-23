class AddSuspensionToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :suspended_at, :datetime
    add_column :users, :suspension_reason, :string
  end
end
