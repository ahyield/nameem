import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  emailForm(){
    this.hideAccountForm()
    this.showEmailForm()
  }

  signupForm() {
    this.showAccountForm()
    this.hideEmailForm()
  }

  hideAccountForm() {
    const newAccountForm = document.querySelector(".new-account-form")
    newAccountForm.classList.add("hidden")
  }

  showAccountForm() {
    const newAccountForm = document.querySelector(".new-account-form")
    newAccountForm.classList.remove("hidden")
  }

  hideEmailForm() {
    const emailForm = document.querySelector(".email-form")
    emailForm.classList.add("hidden")
  }

  showEmailForm() {
    const emailForm = document.querySelector(".email-form")
    emailForm.classList.remove("hidden")
  }
}
