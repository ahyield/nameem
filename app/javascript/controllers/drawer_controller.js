import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "overlay", "panel", "closeButton"]

  open() {
    this.containerTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.overlayTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("-translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
      if (this.hasCloseButtonTarget) {
        this.closeButtonTarget.classList.remove("opacity-0")
        this.closeButtonTarget.classList.add("opacity-100")
      }
    })

    document.body.style.overflow = "hidden"
  }

  close() {
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("-translate-x-full")
    if (this.hasCloseButtonTarget) {
      this.closeButtonTarget.classList.remove("opacity-100")
      this.closeButtonTarget.classList.add("opacity-0")
    }

    document.body.style.overflow = ""

    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
    }, 500)
  }

  outside(event) {
    if (!this.panelTarget.contains(event.target)) {
      this.close()
    }
  }

  escape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
