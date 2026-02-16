class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include Pundit::Authorization

  before_action :authenticate_user!
end
