import { Controller } from "@hotwired/stimulus"

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

  // Unpublishing hides the article from readers, so ask first
  confirmUnpublish(event) {
    if (!window.confirm("سيختفي الموضوع عن القرّاء ويعود مسودة. هل تريد إلغاء نشره؟")) {
      event.preventDefault()
    }
  }

  escape(event) {
    if (event.key === "Escape") this.closeModal()
  }

  closeModal() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
