module Api
  class ApiBaseController < ActionController::API
    include ActionController::Helpers
    include ActionController::Cookies
    include Authentication
    include Pundit::Authorization
    include SuspensionGuard

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    private

    def redirect_to_login
      render json: { error: "unauthorized" }, status: :unauthorized
    end

    def render_not_found
      render json: { error: "not_found" }, status: :not_found
    end

    def render_unprocessable(exception)
      render json: { error: exception.message }, status: :unprocessable_content
    end

    def render_forbidden
      render json: { error: "forbidden" }, status: :forbidden
    end
  end
end
