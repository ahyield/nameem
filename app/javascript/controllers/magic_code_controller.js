import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  onInput() {
    const input = this.inputTarget
    input.value = input.value.toUpperCase().replace(/[^A-Z0-9]/g, "")

    if (input.value.length === 6) {
      this.submitTarget.closest("form").requestSubmit()
    }
  }

  onPaste(event) {
    event.preventDefault()
    const paste = (event.clipboardData || window.clipboardData).getData("text")
    const cleaned = paste.trim().toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6)
    this.inputTarget.value = cleaned

    if (cleaned.length === 6) {
      this.submitTarget.closest("form").requestSubmit()
    }
  }
}
