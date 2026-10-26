import { Controller } from "@hotwired/stimulus"

// A one-off notice: closing it is remembered for a year so it doesn't come back
export default class extends Controller {
  static values = { cookie: String }

  dismiss() {
    document.cookie = `${this.cookieValue}=1; path=/; max-age=31536000; samesite=lax`
    this.element.classList.add("is-leaving")
    setTimeout(() => this.element.remove(), 160)
  }
}
