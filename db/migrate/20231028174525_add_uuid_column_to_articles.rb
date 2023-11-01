# frozen_string_literal: true

class AddUuidColumnToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :uuid, :binary, limit: 16
  end
end
