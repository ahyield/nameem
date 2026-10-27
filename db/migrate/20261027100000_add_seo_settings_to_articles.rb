class AddSeoSettingsToArticles < ActiveRecord::Migration[8.2]
  def change
    change_table :articles, bulk: true do |t|
      t.string :seo_title, limit: 70
      t.string :canonical_url
      t.boolean :noindex, default: false, null: false
      t.string :cover_image_src, limit: 1024
    end
  end
end
