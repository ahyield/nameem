import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("[data-tweet-id]").forEach((el) => {
      if (window.twttr?.widgets) {
        twttr.widgets.createTweet(el.dataset.tweetId, el)
      }
    })
  }
}
