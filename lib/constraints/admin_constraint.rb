module Constraints
  class AdminConstraint
    def matches?(request)
      request.session[:user_id].present? && User.find(request.session[:user_id]).admin?
    end
  end
end
