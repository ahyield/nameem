import { Controller } from "@hotwired/stimulus"
import { confirmDialog } from "lib/confirm_dialog"

const DESCRIPTION_LIMIT = 160
const DESCRIPTION_WARNING = 140

export default class extends Controller {
  static targets = ["description", "charCount"]

  updateDescription() {
    const length = this.descriptionTarget.value.length
    this.charCountTarget.textContent = `${length} / ${DESCRIPTION_LIMIT}`
    this.charCountTarget.classList.toggle("text-orange-700", length >= DESCRIPTION_WARNING)
    this.charCountTarget.classList.toggle("text-gray-500", length < DESCRIPTION_WARNING)
  }

  // Unpublishing hides the article from readers, so ask first; once confirmed, submit with the same button
  async confirmUnpublish(event) {
    const button = event.currentTarget
    if (button.dataset.confirmed) return

    event.preventDefault()
    const confirmed = await confirmDialog("سيختفي الموضوع عن القرّاء ويعود مسودة. هل تريد إلغاء نشره؟", {
      confirmLabel: "إلغاء النشر", cancelLabel: "تراجع", destructive: true
    })
    if (confirmed) {
      button.dataset.confirmed = "true"
      button.form.requestSubmit(button)
    }
  }

  escape(event) {
    // Escape inside an open confirm dialog only closes that dialog
    if (event.key === "Escape" && !document.querySelector("dialog.confirm-dialog[open]")) this.closeModal()
  }

  closeModal() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
