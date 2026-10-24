class AddMostlyLatinToArticles < ActiveRecord::Migration[8.2]
  def up
    add_column :articles, :mostly_latin, :boolean, default: false, null: false

    # Classify existing articles; new and edited ones are classified on save (Metable)
    select_rows("SELECT id, title, content_html FROM articles").each do |id, title, content_html|
      next unless ArticleLanguage.mostly_latin?(title, content_html)

      execute "UPDATE articles SET mostly_latin = TRUE WHERE id = #{Integer(id)}"
    end
  end

  def down
    remove_column :articles, :mostly_latin
  end
end
