module Constraints
  # Routes only admins can reach (Mission Control). Reads the same signed session cookie as Authentication.
  class AdminConstraint
    def matches?(request)
      session = Session.find_signed(request.cookie_jar[:session_token])
      session&.user&.admin? || false
    end
  end
end
