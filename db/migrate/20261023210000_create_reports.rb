class CreateReports < ActiveRecord::Migration[8.2]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reportable, polymorphic: true, null: false, index: false
      t.references :reported_user, foreign_key: { to_table: :users, on_delete: :nullify }
      t.integer :reason, null: false
      t.text :details
      t.text :snapshot
      t.integer :status, null: false, default: 0
      t.references :reviewer, foreign_key: { to_table: :users, on_delete: :nullify }
      t.datetime :reviewed_at
      t.text :resolution_note
      t.timestamps
    end

    add_index :reports, %i[reporter_id reportable_type reportable_id], unique: true, name: "index_reports_on_reporter_and_reportable"
    add_index :reports, %i[reportable_type reportable_id]
    add_index :reports, %i[status created_at]
  end
end
