class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include Pundit::Authorization
  include SuspensionGuard

  before_action :set_canonical_url

  # Answer "not allowed" like "not found", so we don't reveal that someone else's draft exists
  rescue_from Pundit::NotAuthorizedError, with: :render_not_found

  private

  def render_not_found
    respond_to do |format|
      format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
      format.any { head :not_found }
    end
  end

  def set_canonical_url
    set_meta_tags canonical: request.original_url
  end
end
