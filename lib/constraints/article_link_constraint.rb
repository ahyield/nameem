module Constraints
  # An article's address: its readable permalink (words-01bc2c65) or, for older links, its full UUID
  class ArticleLinkConstraint
    def matches?(request)
      param = request.path_parameters[:uuid].to_s

      ArticleUuidConstraint.new.matches?(request) || Permalinkable::PERMALINK.match?(param)
    end
  end
end
