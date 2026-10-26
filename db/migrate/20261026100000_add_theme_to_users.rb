class AddThemeToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :theme, :string, default: "system", null: false
  end
end
