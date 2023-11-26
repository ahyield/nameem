class AddEditorAndAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :editor, :boolean, default: false, null: false
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
