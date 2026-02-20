import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input", "results", "backdrop", "panel"]

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
    this.restoreScroll()
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.inputTarget.focus()
    })
    document.body.style.overflow = "hidden"
  }

  close() {
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
      this.inputTarget.value = ""
      this.resultsTarget.innerHTML = ""
    }, 150)
    this.restoreScroll()
  }

  closeOnBackdrop(event) {
    if (!this.panelTarget.contains(event.target)) {
      this.close()
    }
  }

  input() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()
    if (query.length === 0) {
      this.resultsTarget.innerHTML = ""
      return
    }
    this.debounceTimer = setTimeout(() => this.fetchResults(query), 200)
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    } else if (event.key === "Enter") {
      event.preventDefault()
      const query = this.inputTarget.value.trim()
      if (query.length > 0) {
        this.close()
        window.location.href = `/search?q=${encodeURIComponent(query)}`
      }
    }
  }

  async fetchResults(query) {
    try {
      const response = await fetch(`/search/autocomplete?q=${encodeURIComponent(query)}`)
      if (!response.ok) return
      const data = await response.json()
      this.renderResults(data, query)
    } catch { /* ignore */ }
  }

  renderResults(data, query) {
    const { people, articles, topics } = data
    const hasResults = people.length > 0 || articles.length > 0 || topics.length > 0

    if (!hasResults) {
      this.resultsTarget.innerHTML = `
        <div class="p-6 text-center text-gray-500">
          <p>لا توجد نتائج</p>
        </div>
      `
      return
    }

    let html = ""

    if (people.length > 0) {
      html += `<div class="border-b border-gray-100 px-4 py-3">
        <h3 class="text-xs font-semibold text-gray-400 uppercase mb-2">الكتّاب</h3>`
      people.forEach(person => {
        const avatar = person.avatar_url
          ? `<img src="${person.avatar_url}" class="h-8 w-8 rounded-full bg-gray-50 object-cover" />`
          : `<span class="inline-block h-8 w-8 overflow-hidden rounded-full bg-gray-100">
              <svg class="h-full w-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
                <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
            </span>`
        html += `<a href="/${person.slug}" class="flex items-center gap-3 rounded-lg px-2 py-2 hover:bg-gray-50" data-turbo="false">
          ${avatar}
          <span class="text-sm font-medium text-gray-900">${this.escapeHtml(person.name)}</span>
        </a>`
      })
      html += `</div>`
    }

    if (articles.length > 0) {
      html += `<div class="border-b border-gray-100 px-4 py-3">
        <h3 class="text-xs font-semibold text-gray-400 uppercase mb-2">المقالات</h3>`
      articles.forEach(article => {
        html += `<a href="/${article.slug}/${article.uuid}" class="flex items-center gap-3 rounded-lg px-2 py-2 hover:bg-gray-50" data-turbo="false">
          <svg class="h-5 w-5 text-gray-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
          </svg>
          <span class="text-sm text-gray-900 line-clamp-1">${this.escapeHtml(article.title || "بدون عنوان")}</span>
        </a>`
      })
      html += `</div>`
    }

    if (topics.length > 0) {
      html += `<div class="px-4 py-3">
        <h3 class="text-xs font-semibold text-gray-400 uppercase mb-2">المواضيع</h3>`
      topics.forEach(topic => {
        html += `<a href="/topics/${topic.slug}" class="flex items-center gap-3 rounded-lg px-2 py-2 hover:bg-gray-50" data-turbo="false">
          <svg class="h-5 w-5 text-gray-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5.25 8.25h15m-16.5 7.5h15m-1.8-13.5l-3.9 19.5m-2.1-19.5l-3.9 19.5" />
          </svg>
          <span class="text-sm text-gray-900">${this.escapeHtml(topic.name)}</span>
        </a>`
      })
      html += `</div>`
    }

    html += `<div class="border-t border-gray-100 px-4 py-3">
      <a href="/search?q=${encodeURIComponent(query)}" class="block text-center text-sm text-blue-500 hover:text-blue-700" data-turbo="false">
        عرض جميع النتائج
      </a>
    </div>`

    this.resultsTarget.innerHTML = html
  }

  restoreScroll() {
    document.body.style.overflow = ""
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
