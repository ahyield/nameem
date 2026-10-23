import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { viewableType: String, viewableId: Number }

  connect() {
    this.trackView()
  }

  async trackView() {
    try {
      const FingerprintJS = await import("@fingerprintjs/fingerprintjs")
      const fp = await (FingerprintJS.default || FingerprintJS).load()
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
    } catch {
      // Silently fail — view tracking is non-critical
    }
  }
}
