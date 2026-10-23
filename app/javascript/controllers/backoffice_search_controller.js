import { Controller } from "@hotwired/stimulus"

const REFOCUS_KEY = "backoffice-search-refocus"

export default class extends Controller {
  static targets = ["form", "input"]

  connect() {
    this.timeout = null

    // Results reload as the user types; put the cursor back where it was
    if (sessionStorage.getItem(REFOCUS_KEY)) {
      sessionStorage.removeItem(REFOCUS_KEY)
      const end = this.inputTarget.value.length
      this.inputTarget.focus()
      this.inputTarget.setSelectionRange(end, end)
    }
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      sessionStorage.setItem(REFOCUS_KEY, "1")
      this.formTarget.requestSubmit()
    }, 300)
  }
}
