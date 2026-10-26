// Light/dark theme. <html data-theme> holds the reader's choice (system, light or dark) and the .dark class
// holds what's showing; "system" follows the device.
export const THEMES = ["system", "light", "dark"]
export const THEME_COLORS = { light: "#ffffff", dark: "#1b1916" }
export const DARK_QUERY = "(prefers-color-scheme: dark)"

export function isDark(theme, systemDark) {
  return theme === "dark" || (theme === "system" && systemDark)
}

export function applyTheme(root, theme, systemDark) {
  const dark = isDark(theme, systemDark)
  root.dataset.theme = theme
  root.classList.toggle("dark", dark)
  root.querySelectorAll("meta[name='theme-color']").forEach((meta) => { meta.content = THEME_COLORS[dark ? "dark" : "light"] })
  return dark
}

// Keep "system" in step when the device switches between light and dark
export function followSystemTheme(root, media) {
  media.addEventListener("change", (event) => {
    if (root.dataset.theme === "system") applyTheme(root, "system", event.matches)
  })
}
