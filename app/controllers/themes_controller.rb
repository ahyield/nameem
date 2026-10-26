class ThemesController < ApplicationController
  skip_before_action :require_authentication
  before_action :resume_session

  def update
    theme = params[:theme].to_s
    if ThemePreference::THEMES.include?(theme)
      remember_theme(theme)
      current_user&.update!(theme: theme)
    end

    respond_to do |format|
      format.html { redirect_back_or_to root_path }
      format.any { head :no_content }
    end
  end
end
