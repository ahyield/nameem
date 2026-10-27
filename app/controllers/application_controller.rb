class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include Pundit::Authorization
  include SuspensionGuard
  include ThemePreference

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

  # The page's address without tracking or other query strings, so variants count as one page; later pages
  # of a list keep their page number
  def set_canonical_url
    page = params[:page].to_i
    set_meta_tags canonical: request.base_url + request.path + (page > 1 ? "?page=#{page}" : "")
  end

  # For pages search engines shouldn't list, though they may follow the links on them
  def noindex!
    set_meta_tags noindex: true, follow: true
  end
end
