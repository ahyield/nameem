module Metable
  extend ActiveSupport::Concern

  included do
    def create_description
      ops ||= content.fetch("ops")
      description = ""

      ops.each do |element|
        next unless element.fetch("insert").is_a?(String) && element.fetch("insert").length > 5

        element.fetch("insert").split("\n").compact_blank.each do |line|
          description += line

          break if description.length > 100
        end
      end

      update_column(:description, description)
    end
  end
end
