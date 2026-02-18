class FixConfirmedDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :confirmed, from: nil, to: false
    change_column_null :users, :confirmed, false, false
  end
end
