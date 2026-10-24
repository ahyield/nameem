import { Controller } from "@hotwired/stimulus"

// Switches the feed to another tab by clicking that tab's link, so the tab highlight and the
// remembered tab (feed_active_link_controller) stay in sync
export default class extends Controller {
  static values = { href: String }

  go() {
    const tab = document.querySelector(`[data-feed-active-link-target="link"][href="${this.hrefValue}"]`)
    if (!tab) return

    tab.click()
    tab.scrollIntoView({ block: "nearest" })
  }
}
