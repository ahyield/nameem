class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include Pundit::Authorization

  before_action :set_canonical_url

  private

  def set_canonical_url
    set_meta_tags canonical: request.original_url
  end
end
