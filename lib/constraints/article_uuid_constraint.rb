module Constraints
  class ArticleUuidConstraint
    def matches?(request)
      uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      request.path_parameters[:uuid].present? && uuid_regex.match?(request.path_parameters[:uuid])
    end
  end
end
