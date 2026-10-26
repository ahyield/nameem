# Mission Control (/backoffice/jobs) runs on this instead of HTTP basic auth: signed-in admins only
class MissionControlBaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    render_not_found unless current_user&.admin?
  end
end
