module Metable
  extend ActiveSupport::Concern

  included do
    after_update :create_description

    def create_description
      description = ""

      ops.each do |element|
        next unless element.fetch("insert").is_a?(String) && element.fetch("insert").length >= 3

        element.fetch("insert").split("\n").compact_blank.each do |line|
          description += "#{line}\n"

          break if description.length > 100
        end
      end

      update_column(:description, description)
    end

    def alternative_titles
      titles = []

      ops.each do |element|
        titles << element.fetch("insert") if element.fetch("insert").is_a?(String) && element.fetch("insert").size >= 5
      end

      titles
    end

    def article_images
      urls = []

      ops.each do |element|
        if element.fetch("insert").include?("customImage") && element.fetch("insert").key?("customImage")
          urls << element.fetch("insert").fetch("customImage").fetch("url")
        end
      end

      urls
    end
  end
end
