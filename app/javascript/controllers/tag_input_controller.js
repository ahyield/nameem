import { Controller } from "@hotwired/stimulus"

const REMOVE_ICON = "<svg class='h-3.5 w-3.5' viewBox='0 0 20 20' fill='currentColor' aria-hidden='true'><path d='M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z'/></svg>"

export default class extends Controller {
  static targets = ["input", "pills", "hiddenFields", "suggestions"]
  static values = { max: { type: Number, default: 5 }, existing: { type: Array, default: [] } }

  connect() {
    this.tags = [...this.existingValue]
    this.render()
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
  }

  keydown(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault()
      this.addTag()
      this.hideSuggestions()
    } else if (event.key === "Escape") {
      this.hideSuggestions()
    }
  }

  input() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()
    if (query.length === 0) {
      this.hideSuggestions()
      return
    }
    this.debounceTimer = setTimeout(() => this.fetchSuggestions(query), 200)
  }

  async fetchSuggestions(query) {
    try {
      const response = await fetch(`/topics/search?q=${encodeURIComponent(query)}`)
      if (!response.ok) return
      const names = await response.json()
      const filtered = names.filter(name => !this.tags.includes(name))
      this.showSuggestions(filtered)
    } catch { /* ignore */ }
  }

  // Tag names come from other users, so build nodes with textContent rather than HTML strings
  showSuggestions(names) {
    if (names.length === 0 || !this.hasSuggestionsTarget) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.replaceChildren(...names.map(name => {
      const button = document.createElement("button")
      button.type = "button"
      button.dataset.action = "click->tag-input#selectSuggestion"
      button.dataset.name = name
      button.className = "w-full px-3 py-2 text-right text-sm text-gray-700 hover:bg-gray-100 cursor-pointer"
      button.textContent = name
      return button
    }))
    this.suggestionsTarget.classList.remove("hidden")
  }

  hideSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.classList.add("hidden")
      this.suggestionsTarget.replaceChildren()
    }
  }

  selectSuggestion(event) {
    event.preventDefault()
    const name = event.currentTarget.dataset.name
    if (name && !this.tags.includes(name) && this.tags.length < this.maxValue) {
      this.tags.push(name)
      this.inputTarget.value = ""
      this.render()
    }
    this.hideSuggestions()
  }

  addTag() {
    const name = this.inputTarget.value.trim().replace(/,/g, "")
    if (name === "" || this.tags.includes(name) || this.tags.length >= this.maxValue) return

    this.tags.push(name)
    this.inputTarget.value = ""
    this.render()
  }

  removeTag(event) {
    const name = event.currentTarget.dataset.tag
    this.tags = this.tags.filter(t => t !== name)
    this.render()
  }

  render() {
    this.pillsTarget.replaceChildren(...this.tags.map(tag => this.pill(tag)))
    this.hiddenFieldsTarget.replaceChildren(...this.tags.map(tag => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "tag_names[]"
      input.value = tag
      return input
    }))
  }

  pill(tag) {
    const pill = document.createElement("span")
    pill.className = "inline-flex items-center gap-x-1 rounded-full bg-gray-100 py-1 pr-3 pl-1.5 text-sm font-medium text-gray-700"
    pill.append(tag)

    const remove = document.createElement("button")
    remove.type = "button"
    remove.dataset.action = "click->tag-input#removeTag"
    remove.dataset.tag = tag
    remove.className = "inline-flex h-5 w-5 items-center justify-center rounded-full text-gray-400 hover:bg-gray-200 hover:text-gray-700 cursor-pointer"
    remove.setAttribute("aria-label", `إزالة ${tag}`)
    remove.innerHTML = REMOVE_ICON
    pill.append(remove)
    return pill
  }
}
