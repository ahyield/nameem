import { Controller } from "@hotwired/stimulus"
import FingerprintJS from "@fingerprintjs/fingerprintjs"

export default class extends Controller {
  static values = { viewableType: String, viewableId: Number }

  connect() {
    this.trackView()
  }

  async trackView() {
    try {
      const fp = await FingerprintJS.load()
      const result = await fp.get()

      const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

      await fetch("/api/views", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          viewable_type: this.viewableTypeValue,
          viewable_id: this.viewableIdValue,
          visitor_id: result.visitorId,
        }),
      })
    } catch (e) {
      // Silently fail — view tracking is non-critical
    }
  }
}
