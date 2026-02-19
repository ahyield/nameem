class AddReadingTimeMinutesToArticles < ActiveRecord::Migration[8.2]
  def change
    add_column :articles, :reading_time_minutes, :integer
  end
end
