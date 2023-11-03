import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  emailForm(){
    this.hideLoginAccountsForm()
    this.showEmailForm()
  }

  signInForm() {
    this.showLoginAccountsForm()
    this.hideEmailForm()
  }

  hideLoginAccountsForm() {
    const newAccountForm = document.querySelector(".login-accounts-form")
    newAccountForm.classList.add("hidden")
  }

  showLoginAccountsForm() {
    const newAccountForm = document.querySelector(".login-accounts-form")
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
