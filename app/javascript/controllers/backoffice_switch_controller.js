import { Controller } from "@hotwired/stimulus"

// Flips the switch as soon as the form submits, so it responds instantly.
// The page refresh that follows (Turbo morph) confirms the saved state.
export default class extends Controller {
  flip() {
    this.toggle()
  }

  settle(event) {
    if (!event.detail.success) {
      this.toggle()
    }
  }

  toggle() {
    const button = this.element.querySelector("[role=switch]")
    const checked = button.getAttribute("aria-checked") === "true"
    button.setAttribute("aria-checked", String(!checked))
  }
}
