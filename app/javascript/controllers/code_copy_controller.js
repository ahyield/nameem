import { Controller } from "@hotwired/stimulus"
import { codeText } from "lib/code_text"

// A «نسخ» button on each code block in an article
export default class extends Controller {
  connect() {
    this.element.querySelectorAll("pre").forEach((pre) => {
      if (pre.querySelector("[data-code-copy-ignore]")) return

      const button = document.createElement("button")
      button.type = "button"
      button.className = "code-copy"
      button.textContent = "نسخ"
      button.dataset.codeCopyIgnore = ""
      button.addEventListener("click", () => this.copy(pre, button))
      pre.append(button)
    })
  }

  async copy(pre, button) {
    try {
      await navigator.clipboard.writeText(codeText(pre))
      button.textContent = "تم النسخ"
    } catch {
      button.textContent = "تعذّر النسخ"
    }
    clearTimeout(button.resetTimer)
    button.resetTimer = setTimeout(() => { button.textContent = "نسخ" }, 1500)
  }
}
