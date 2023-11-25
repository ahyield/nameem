class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!
end
