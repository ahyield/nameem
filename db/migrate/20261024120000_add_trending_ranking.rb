class AddTrendingRanking < ActiveRecord::Migration[8.2]
  def change
    change_table :articles, bulk: true do |t|
      t.float :trending_score, default: 0, null: false
      t.integer :trending_rank
      t.index :trending_rank
    end

    change_table :page_views, bulk: true do |t|
      t.references :user, foreign_key: { on_delete: :nullify }
      t.datetime :read_at
    end
  end
end
