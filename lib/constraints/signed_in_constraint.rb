module Constraints
  class SignedInConstraint
    def matches?(request)
      request.session[:user_id].present?
    end
  end
end
