module Constraints
  class RootNamespaceRoutesConstraint
    TOP_LEVEL_ROUTES = Constraints::ReservedSlugs::RESERVED_SLUGS

    def matches?(request)
      request.path_parameters[:slug].present? && TOP_LEVEL_ROUTES.exclude?(request.path_parameters[:slug])
    end
  end
end
