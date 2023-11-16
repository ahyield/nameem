module Metable
  included do
    def create_description
      ops ||= content.fetch("ops")
      description = ""

      ops.each do |element|
        next unless element.fetch("insert").is_a(String) && element.fetch("insert") >= 500

        element.fetch("insert").split("\n").each do |line|
          description += "#{line}\n"
        end
      end

      update(description: description)
    end
  end
end
