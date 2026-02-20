class AddSocialLinksToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :website_url, :string
    add_column :users, :twitter_handle, :string
    add_column :users, :instagram_handle, :string
  end
end
