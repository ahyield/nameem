import { Controller } from "@hotwired/stimulus"

export default class extends Controller{
  static targets = ["link"]

  initialize(){
    this.handleTurboClick = this.handleTurboClick.bind(this)

    const savedHref = sessionStorage.getItem("feedActiveTab")
    let activeIndex = 0

    if (savedHref) {
      const found = this.linkTargets.findIndex(t => t.getAttribute("href") === savedHref)
      if (found >= 0) activeIndex = found
    }

    this.linkTargets.forEach((target, index) => {
      if(index === activeIndex){
        target.classList.add("border-gray-400", "text-gray-600")
        target.classList.remove("border-transparent", "text-gray-400", "hover:text-gray-600")
      }else{
        target.classList.add("border-transparent", "text-gray-400", "hover:text-gray-600")
        target.classList.remove("border-gray-400", "text-gray-600")
      }
    })
  }

  connect(){
    this.element.addEventListener("click", this.handleTurboClick)
    this.clearFeed()
    this.clearFeedPagination()

    const savedHref = sessionStorage.getItem("feedActiveTab")
    if (savedHref) {
      const activeLink = this.linkTargets.find(t => t.getAttribute("href") === savedHref)
      if (activeLink) {
        const feedFrame = document.getElementById("feed")
        if (feedFrame) {
          feedFrame.setAttribute("src", savedHref + ".turbo_stream")
        }
      }
    }
  }

  disconnect(){
    this.element.removeEventListener("click", this.handleTurboClick)
    this.clearFeed()
    this.clearFeedPagination()
  }

  handleTurboClick(event){
    if (!this.linkTargets.includes(event.target)) return

    sessionStorage.setItem("feedActiveTab", event.target.getAttribute("href"))

    this.clearFeed()
    this.clearFeedPagination()
    this.linkTargets.forEach(target => {
      if(target == event.target){
        target.classList.add("border-gray-400", "text-gray-600")
        target.classList.remove("border-transparent", "text-gray-400", "hover:text-gray-600")
      }else{
        target.classList.remove("border-gray-400", "text-gray-600")
        target.classList.add("border-transparent", "text-gray-400", "hover:text-gray-600")
      }
    })
  }

  clearFeed() {
    const feedForm = document.getElementById("feed")
    if (feedForm) {
      feedForm.innerHTML = ""
    }
  }
  clearFeedPagination() {
    const feedPagination = document.getElementById("feed_pagination")
    if (feedPagination) {
      feedPagination.innerHTML = ""
    }
  }
}
