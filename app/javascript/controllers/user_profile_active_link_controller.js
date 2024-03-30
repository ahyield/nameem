import { Controller } from "@hotwired/stimulus"

export default class extends Controller{
  static targets = ["link"]

  initialize(){
    this.handleTurboClick = this.handleTurboClick.bind(this)
    this.linkTargets[0].classList.add("border-gray-400", "text-gray-600")
    if(this.linkTargets[1]) {
      this.linkTargets[1].classList.add("border-transparent", "text-gray-400", "hover:text-gray-600")
    }
  }

  connect(){
    this.element.addEventListener("click", this.handleTurboClick)
    this.clearFeed()
    this.clearFeedPagination()
  }

  disconnect(){
    this.element.removeEventListener("click", this.handleTurboClick)
    this.clearFeed()
    this.clearFeedPagination()
  }

  handleTurboClick(event){
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
    const feedForm = document.getElementById("articles")
    if (feedForm) {
      feedForm.innerHTML = ""
    }
  }
  clearFeedPagination() {
    const feedPagination = document.getElementById("articles_pagination")
    if (feedPagination) {
      feedPagination.innerHTML = ""
    }
  }
}
