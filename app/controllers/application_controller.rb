class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend

  before_action :authenticate_user!
end
