module Api
  class ApiBaseController < ActionController::API
    include ActionController::Helpers
    include Authentication
    include Pundit::Authorization
  end
end
