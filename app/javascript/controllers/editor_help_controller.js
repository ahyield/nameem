import { Controller } from "@hotwired/stimulus"

// The editor's «?» guide
export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // A click on the dimmed area around the dialog (the dialog element itself, outside its content) closes it
  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
