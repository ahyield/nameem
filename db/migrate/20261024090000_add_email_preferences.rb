class AddEmailPreferences < ActiveRecord::Migration[8.2]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :email_comments, default: true, null: false
      t.boolean :email_editorial, default: true, null: false
      t.boolean :email_weekly, default: true, null: false
      t.datetime :email_suppressed_at
      t.string :email_suppression_reason
    end

    add_column :notifications, :emailed_at, :datetime
  end
end
