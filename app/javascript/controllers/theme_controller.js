import { Controller } from "@hotwired/stimulus"
import { applyTheme, DARK_QUERY } from "lib/theme"

// The theme menu: picking light, dark or automatic recolours the page at once and remembers the choice
export default class extends Controller {
  static targets = ["option"]
  static values = { url: String }

  connect() {
    this.mark()
  }

  choose(event) {
    const theme = event.currentTarget.dataset.theme
    const root = document.documentElement

    root.classList.add("theme-switching")
    applyTheme(root, theme, window.matchMedia(DARK_QUERY).matches)
    requestAnimationFrame(() => requestAnimationFrame(() => root.classList.remove("theme-switching")))
    this.mark()

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      },
      body: JSON.stringify({ theme }),
      credentials: "same-origin"
    })
  }

  // Every theme picker on the page (the nav menu and the settings row) shows the same choice
  mark() {
    const current = document.documentElement.dataset.theme
    document.querySelectorAll("[data-theme-target='option']").forEach((option) => {
      option.setAttribute("aria-checked", option.dataset.theme === current)
    })
  }
}
