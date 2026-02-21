import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["description", "charCount", "previewDescription"]

  connect() {
    const modal = document.querySelector(".modal")
    modal.classList.add("ease-out", "duration-300", "opacity-100")

    const modalPanel = document.querySelector(".modal-panel")
    modalPanel.classList.add("opacity-100", "translate-y-4", "sm:translate-y-0", "sm:scale-95", "ease-out", "duration-600")

    const publishBtn = document.querySelector(".publish-btn")
    const titleBox = document.querySelector(".title-box")
    const titleNeeded = document.querySelector(".title-needed")

    if (titleBox.contains(titleNeeded)) {
      publishBtn.disabled = true
    }
  }

  updateDescription() {
    const value = this.descriptionTarget.value
    this.charCountTarget.textContent = value.length
  }

  closeModal(event) {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
