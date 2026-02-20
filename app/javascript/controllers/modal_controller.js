import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "overlay", "panel"]

  open() {
    this.containerTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.overlayTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("opacity-0", "scale-95")
      this.panelTarget.classList.add("opacity-100", "scale-100")
    })

    document.body.style.overflow = "hidden"
  }

  close() {
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("opacity-100", "scale-100")
    this.panelTarget.classList.add("opacity-0", "scale-95")

    document.body.style.overflow = ""

    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
    }, 200)
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
