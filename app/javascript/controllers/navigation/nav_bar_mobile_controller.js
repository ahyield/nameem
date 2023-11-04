import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.state = "closed"
    this.mobileMenu = document.querySelector(".mobile-menu")
    this.iconMenuOpen = document.querySelector(".icon-menu-open")
    this.iconMenuClosed = document.querySelector(".icon-menu-closed")
  }

  toggleMenu() {
    if(this.state === "closed") {
      this.mobileMenu.classList.remove("hidden")
      this.iconMenuOpen.classList.add("hidden")
      this.iconMenuOpen.classList.remove("block")
      this.iconMenuClosed.classList.remove("hidden")
      this.iconMenuClosed.classList.add("block")
      this.state = "opened"
    } else if(this.state === "opened") {
      this.mobileMenu.classList.add("hidden")
      this.iconMenuOpen.classList.add("block")
      this.iconMenuOpen.classList.remove("hidden")
      this.iconMenuClosed.classList.remove("block")
      this.iconMenuClosed.classList.add("hidden")
      this.state = "closed"
    }
  }


}
