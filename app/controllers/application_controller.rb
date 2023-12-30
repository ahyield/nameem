class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!

  if ENV["DISALLOW_ALL_WEB_CRAWLERS"].present?
    http_basic_authenticate_with(
      name:     Rails.application.credentials.dig(:http_basic_auth, :username),
      password: Rails.application.credentials.dig(:http_basic_auth, :password)
    )
  end
end
