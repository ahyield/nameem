import { Controller } from "@hotwired/stimulus"

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

  showSuggestions(names) {
    if (names.length === 0 || !this.hasSuggestionsTarget) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.innerHTML = names.map(name =>
      `<button type="button" data-action="click->tag-input#selectSuggestion" data-name="${name}"
              class="w-full text-right px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer">
        ${name}
      </button>`
    ).join("")
    this.suggestionsTarget.classList.remove("hidden")
  }

  hideSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.classList.add("hidden")
      this.suggestionsTarget.innerHTML = ""
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
    this.pillsTarget.innerHTML = this.tags.map(tag =>
      `<span class="inline-flex items-center gap-x-1 rounded-full bg-blue-50 px-3 py-1 text-sm font-medium text-blue-700">
        ${tag}
        <button type="button" data-action="click->tag-input#removeTag" data-tag="${tag}" class="cursor-pointer text-blue-400 hover:text-blue-600">
          <svg class="h-3.5 w-3.5" viewBox="0 0 20 20" fill="currentColor"><path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/></svg>
        </button>
      </span>`
    ).join("")

    this.hiddenFieldsTarget.innerHTML = this.tags.map(tag =>
      `<input type="hidden" name="tag_names[]" value="${tag}">`
    ).join("")
  }
}
