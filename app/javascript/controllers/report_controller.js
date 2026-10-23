import { Controller } from "@hotwired/stimulus"

// One report dialog per page: each "report" button passes the item it reports
export default class extends Controller {
  static targets = ["dialog", "form", "type", "id", "title", "result"]

  open({ params: { type, id, title } }) {
    this.typeTarget.value = type
    this.idTarget.value = id
    this.titleTarget.textContent = title
    this.formTarget.reset()
    this.formTarget.hidden = false
    this.resultTarget.innerHTML = ""
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // Clicks on the backdrop land on the <dialog> element itself
  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  // Escape closes only this dialog, not the comments drawer behind it
  keydown(event) {
    if (event.key === "Escape") event.stopPropagation()
  }

  submitted(event) {
    if (event.detail.success) {
      this.formTarget.hidden = true
    } else {
      this.resultTarget.textContent = "تعذّر إرسال البلاغ. إذا اخترت «سبب آخر» فاكتب التفاصيل."
    }
  }
}
