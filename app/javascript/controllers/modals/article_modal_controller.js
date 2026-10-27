import { Controller } from "@hotwired/stimulus"
import { confirmDialog } from "lib/confirm_dialog"
import { slugify } from "lib/slug"

const DESCRIPTION_LIMIT = 160
const DESCRIPTION_WARNING = 140
const SEO_TITLE_LIMIT = 70

export default class extends Controller {
  static targets = ["description", "charCount", "seoTitle", "seoTitleCount", "slug", "previewTitle", "previewSlug",
    "previewDescription", "cover"]
  static values = { closeUrl: String, defaultTitle: String }

  updateDescription() {
    const length = this.descriptionTarget.value.length
    this.charCountTarget.textContent = `${length} / ${DESCRIPTION_LIMIT}`
    this.charCountTarget.classList.toggle("text-orange-700", length >= DESCRIPTION_WARNING)
    this.charCountTarget.classList.toggle("text-gray-500", length < DESCRIPTION_WARNING)
  }

  // Keeps the search-result preview in step with the title, address and description fields
  updatePreview() {
    if (this.hasSeoTitleTarget) {
      const title = this.seoTitleTarget.value.trim()
      this.seoTitleCountTarget.textContent = `${title.length} / ${SEO_TITLE_LIMIT}`
      this.previewTitleTarget.textContent = `${title || this.defaultTitleValue} — نميم`
    }
    if (this.hasSlugTarget) {
      this.previewSlugTarget.textContent = slugify(this.slugTarget.value) || slugify(this.slugTarget.placeholder)
    }
    if (this.hasPreviewDescriptionTarget) this.previewDescriptionTarget.textContent = this.descriptionTarget.value
  }

  // Shows the address as it will be saved once the field is left
  tidySlug() {
    this.slugTarget.value = slugify(this.slugTarget.value)
    this.updatePreview()
  }

  chooseCover(event) {
    if (this.hasCoverTarget) this.coverTarget.src = event.currentTarget.dataset.coverUrl
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
    // Shown as its own page after a failed save, closing goes back to the editor
    if (!this.element.closest("turbo-frame")?.hasAttribute("src")) {
      window.location.href = this.closeUrlValue
      return
    }
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
