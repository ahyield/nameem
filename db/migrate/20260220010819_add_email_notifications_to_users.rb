class AddEmailNotificationsToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :email_notifications, :boolean, default: true, null: false
  end
end
