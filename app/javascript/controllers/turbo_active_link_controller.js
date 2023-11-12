import { Controller } from "@hotwired/stimulus"

export default class extends Controller{
  static targets = ["link"]

  initialize(){
    this.handleTurboClick = this.handleTurboClick.bind(this)
    this.linkTargets[0].classList.add("border-blue-500", "text-blue-600")
    this.linkTargets[1].classList.add("border-transparent", "text-gray-700", "hover:border-gray-300", "hover:text-gray-500")
    this.linkTargets[2].classList.add("border-transparent", "text-gray-700", "hover:border-gray-300", "hover:text-gray-500")
  }

  connect(){
    this.element.addEventListener("turbo:click", this.handleTurboClick)
  }

  disconnect(){
    this.element.removeEventListener("turbo:click", this.handleTurboClick)
  }

  handleTurboClick(event){
    this.linkTargets.forEach(target => {
      if(target == event.target){
        target.classList.add("border-blue-500", "text-blue-600")
        target.classList.remove("border-transparent", "text-gray-700", "hover:border-gray-300", "hover:text-gray-500")
      }else{
        target.classList.remove("border-blue-500", "text-blue-600")
        target.classList.add("border-transparent", "text-gray-700", "hover:border-gray-300", "hover:text-gray-500")
      }
    })
  }
}
