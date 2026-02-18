module Constraints
  class SignedInConstraint
    def matches?(request)
      cookies = ActionDispatch::Request.new(request.env).cookie_jar
      token = cookies[:session_token]
      token.present? && Session.find_signed(token).present?
    end
  end
end
