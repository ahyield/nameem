import { Controller } from "@hotwired/stimulus"
import { isRead, scrolledDepth } from "lib/read_tracker"

// Records a view of the page, and for articles a read once the reader stays and scrolls far enough
export default class extends Controller {
  static values = { viewableType: String, viewableId: Number }
  static targets = ["content"]

  connect() {
    this.depth = 0
    this.trackView()
  }

  disconnect() {
    this.stopWatchingForRead()
  }

  async trackView() {
    try {
      const FingerprintJS = await import("@fingerprintjs/fingerprintjs")
      const fp = await (FingerprintJS.default || FingerprintJS).load()
      this.visitorId = (await fp.get()).visitorId

      await this.send({})
      if (this.hasContentTarget) this.watchForRead()
    } catch {
      // Silently fail — view tracking is non-critical
    }
  }

  watchForRead() {
    this.startedAt = Date.now()
    this.onScroll = () => this.measure()
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.timer = setInterval(() => this.measure(), 5000)
    this.measure()
  }

  measure() {
    const depth = scrolledDepth(this.contentTarget.getBoundingClientRect(), window.innerHeight)
    this.depth = Math.max(this.depth, depth)
    const elapsedSeconds = (Date.now() - this.startedAt) / 1000

    if (isRead({ elapsedSeconds, depth: this.depth })) {
      this.stopWatchingForRead()
      this.send({ read: true }).catch(() => {})
    }
  }

  stopWatchingForRead() {
    if (this.onScroll) window.removeEventListener("scroll", this.onScroll)
    clearInterval(this.timer)
    this.onScroll = null
  }

  send(extra) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    return fetch("/api/views", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
      body: JSON.stringify({
        viewable_type: this.viewableTypeValue,
        viewable_id: this.viewableIdValue,
        visitor_id: this.visitorId,
        ...extra,
      }),
    })
  }
}
