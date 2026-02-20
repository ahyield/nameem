class AddFacebookHandleToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :facebook_handle, :string
  end
end
