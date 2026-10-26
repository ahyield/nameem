class AddEmailNewsToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :email_news, :boolean, default: true, null: false
  end
end
