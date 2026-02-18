module Api
  class ApiBaseController < ActionController::API
    include ActionController::Helpers
    include ActionController::Cookies
    include Authentication
    include Pundit::Authorization
  end
end
