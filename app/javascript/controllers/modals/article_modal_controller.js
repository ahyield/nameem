import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const modal = document.querySelector(".modal")
    modal.classList.add("ease-out", "duration-300", "opacity-100")

    const modalPanel = document.querySelector(".modal-panel")
    modalPanel.classList.add("opacity-100", "translate-y-4", "sm:translate-y-0", "sm:scale-95", "ease-out", "duration-600")
  }

  closeModal(event) {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
