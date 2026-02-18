module Authentication
  module UnauthenticatedAccess
    extend ActiveSupport::Concern

    included do
      skip_before_action :require_authentication
      before_action :try_resume_session
    end

    private

    def redirect_authenticated_user
      redirect_to root_path if authenticated?
    end

    def try_resume_session
      resume_session
    end
  end
end
