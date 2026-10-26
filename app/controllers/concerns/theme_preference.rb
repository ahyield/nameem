# The reader's light/dark choice. A signed-in reader's choice is saved on their account so it follows them to
# other devices; the cookie carries it for signed-out readers and for pages that don't load the session.
module ThemePreference
  extend ActiveSupport::Concern

  THEMES = User.themes.keys.freeze

  included do
    helper_method :current_theme
  end

  private

  def current_theme
    [current_user&.theme, cookies[:theme]].find { |theme| THEMES.include?(theme) } || "system"
  end

  def remember_theme(theme)
    cookies.permanent[:theme] = { value: theme, same_site: :lax }
  end
end
