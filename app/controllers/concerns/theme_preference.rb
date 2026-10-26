# The reader's light/dark choice. A signed-in reader's choice is saved on their account so it follows them to
# other devices; the cookie carries it for signed-out readers and for pages that don't load the session.
module ThemePreference
  extend ActiveSupport::Concern

  THEMES = User.themes.keys.freeze
  # The "dark mode is here" card shows for two weeks after launch, until the reader closes it
  ANNOUNCE_DARK_MODE_UNTIL = Time.zone.parse("2026-11-09 23:59")
  ANNOUNCEMENT_COOKIE = :dark_mode_announced

  included do
    helper_method :current_theme, :announce_dark_mode?
  end

  private

  def announce_dark_mode?
    Time.current <= ANNOUNCE_DARK_MODE_UNTIL && cookies[ANNOUNCEMENT_COOKIE].blank?
  end

  def current_theme
    [current_user&.theme, cookies[:theme]].find { |theme| THEMES.include?(theme) } || "system"
  end

  def remember_theme(theme)
    cookies.permanent[:theme] = { value: theme, same_site: :lax }
  end
end
