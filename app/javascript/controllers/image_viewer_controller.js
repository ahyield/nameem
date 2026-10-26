import { Controller } from "@hotwired/stimulus"
import { clampPan, clampScale, classifySwipe, nextIndex, stepForKey, TAP_ZOOM, zoomAround } from "lib/image_viewer"

const ICONS = {
  close: "M6 18 18 6M6 6l12 12",
  previous: "m8.25 4.5 7.5 7.5-7.5 7.5",
  next: "M15.75 19.5 8.25 12l7.5-7.5",
}
// Only offer zoom when the picture has at least this much more detail than fits on screen
const ZOOMABLE_RATIO = 1.15
const reducedMotion = () => window.matchMedia("(prefers-reduced-motion: reduce)").matches

// Opens an article's images full screen: original quality, caption, next/previous, zoom and pan
export default class extends Controller {
  connect() {
    this.images = [...this.element.querySelectorAll("figure img")]
    this.images.forEach((image, index) => {
      image.tabIndex = 0
      image.setAttribute("role", "button")
      image.setAttribute("aria-label", "عرض الصورة")
      image.addEventListener("click", () => this.open(index))
      image.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault()
          this.open(index)
        }
      })
    })
  }

  disconnect() {
    this.dialog?.remove()
    document.documentElement.style.overflow = ""
  }

  open(index) {
    this.build()
    this.index = index
    this.reset()
    this.show(index)
    document.documentElement.style.overflow = "hidden"
    this.dialog.showModal()
    this.growFrom(this.images[index])
  }

  close() {
    if (this.dialog?.open) this.dialog.close()
  }

  step(direction) {
    if (this.images.length < 2) return
    this.reset()
    this.show(nextIndex(this.index, direction, this.images.length))
  }

  // === Building the viewer ===

  build() {
    if (this.dialog) return

    this.dialog = document.createElement("dialog")
    this.dialog.className = "image-viewer"
    this.dialog.dir = "rtl"
    this.dialog.setAttribute("aria-label", "عارض الصور")

    this.stage = document.createElement("div")
    this.stage.className = "image-viewer-stage"
    this.picture = document.createElement("img")
    this.picture.className = "image-viewer-image"
    this.picture.alt = ""
    this.picture.draggable = false
    this.picture.addEventListener("load", () => this.updateZoomable())
    this.stage.append(this.picture)

    const footer = document.createElement("div")
    footer.className = "image-viewer-footer"
    this.caption = document.createElement("p")
    this.caption.className = "image-viewer-caption"
    this.caption.dir = "auto"
    this.counter = document.createElement("span")
    this.counter.className = "image-viewer-count"
    footer.append(this.caption, this.counter)

    this.dialog.append(
      this.stage,
      this.button("close", "إغلاق", () => this.close()),
      this.button("previous", "الصورة السابقة", () => this.step(-1)),
      this.button("next", "الصورة التالية", () => this.step(1)),
      footer,
    )
    this.dialog.classList.toggle("is-single", this.images.length < 2)
    document.body.append(this.dialog)

    this.dialog.addEventListener("close", () => {
      document.documentElement.style.overflow = ""
      this.images[this.index]?.focus({ preventScroll: true })
    })
    this.dialog.addEventListener("keydown", (event) => {
      const step = stepForKey(event.key, true)
      if (step) {
        event.preventDefault()
        this.step(step)
      }
    })
    this.listenForGestures()
  }

  button(name, label, action) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = `image-viewer-button image-viewer-${name}`
    button.setAttribute("aria-label", label)
    button.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="${ICONS[name]}" /></svg>`
    button.addEventListener("click", action)
    return button
  }

  // Shows the page's (already loaded) reading-size image at once, then the original when it arrives
  show(index) {
    this.index = index
    const image = this.images[index]
    const full = image.dataset.fullSrc || image.currentSrc || image.src
    this.picture.src = image.currentSrc || image.src
    const original = new Image()
    original.onload = () => {
      if (this.index === index) this.picture.src = full
    }
    original.src = full

    const caption = image.closest("figure")?.querySelector("figcaption")?.textContent?.trim() || ""
    this.caption.textContent = caption
    this.caption.hidden = caption === ""
    this.counter.textContent = `${index + 1} / ${this.images.length}`
    this.preload(nextIndex(index, 1, this.images.length))
    this.preload(nextIndex(index, -1, this.images.length))
  }

  preload(index) {
    const image = this.images[index]
    if (image?.dataset.fullSrc) new Image().src = image.dataset.fullSrc
  }

  // The image grows from where it sat in the article
  growFrom(thumbnail) {
    if (reducedMotion()) return
    const from = thumbnail.getBoundingClientRect()
    requestAnimationFrame(() => {
      const to = this.picture.getBoundingClientRect()
      if (!to.width || !to.height) return
      const dx = from.left + from.width / 2 - (to.left + to.width / 2)
      const dy = from.top + from.height / 2 - (to.top + to.height / 2)
      this.picture.animate(
        [{ transform: `translate(${dx}px, ${dy}px) scale(${from.width / to.width})` }, { transform: "none" }],
        { duration: 260, easing: "cubic-bezier(0.23, 1, 0.32, 1)" },
      )
    })
  }

  // === Zoom and pan ===

  reset() {
    this.scale = 1
    this.pan = { x: 0, y: 0 }
    this.apply(false)
  }

  // How far a click zooms: up to the picture's real detail (at most TAP_ZOOM), or 0 when there's nothing to gain
  zoomableScale() {
    const shown = this.picture.offsetWidth
    const ratio = shown ? this.picture.naturalWidth / shown : 0
    return ratio < ZOOMABLE_RATIO ? 0 : Math.min(TAP_ZOOM, Math.max(1.5, ratio))
  }

  updateZoomable() {
    this.dialog.classList.toggle("is-zoomable", this.zoomableScale() > 0)
  }

  apply(animate) {
    if (!this.picture) return
    this.picture.style.transition = animate ? "transform 220ms cubic-bezier(0.23, 1, 0.32, 1)" : "none"
    this.picture.style.transform = `translate(${this.pan.x}px, ${this.pan.y}px) scale(${this.scale})`
    this.dialog.classList.toggle("is-zoomed", this.scale > 1)
  }

  zoomTo(scale, point, animate) {
    const next = clampScale(scale)
    this.pan = this.clamp(zoomAround(point, this.pan, this.scale, next), next)
    this.scale = next
    this.apply(animate)
  }

  clamp(pan, scale) {
    const size = { width: this.picture.offsetWidth, height: this.picture.offsetHeight }
    const viewport = { width: this.stage.clientWidth, height: this.stage.clientHeight }
    return clampPan(pan, scale, size, viewport)
  }

  // A point relative to the centre of the stage, where the image's transform origin sits
  pointFrom(event) {
    const rect = this.stage.getBoundingClientRect()
    return { x: event.clientX - (rect.left + rect.width / 2), y: event.clientY - (rect.top + rect.height / 2) }
  }

  listenForGestures() {
    this.pointers = new Map()

    this.stage.addEventListener("pointerdown", (event) => {
      this.stage.setPointerCapture(event.pointerId)
      this.pointers.set(event.pointerId, { x: event.clientX, y: event.clientY })
      if (this.pointers.size === 1) {
        this.drag = { x: event.clientX, y: event.clientY, pan: { ...this.pan }, time: performance.now(), moved: false }
        this.dialog.classList.add("is-dragging")
      } else if (this.pointers.size === 2) {
        this.pinch = { distance: this.distance(), scale: this.scale }
        this.drag = null
      }
    })

    this.stage.addEventListener("pointermove", (event) => {
      if (!this.pointers.has(event.pointerId)) return
      this.pointers.set(event.pointerId, { x: event.clientX, y: event.clientY })

      if (this.pinch && this.pointers.size === 2) {
        const [a, b] = [...this.pointers.values()]
        const middle = this.pointFrom({ clientX: (a.x + b.x) / 2, clientY: (a.y + b.y) / 2 })
        this.zoomTo(this.pinch.scale * (this.distance() / this.pinch.distance), middle, false)
        return
      }
      if (!this.drag) return

      const dx = event.clientX - this.drag.x
      const dy = event.clientY - this.drag.y
      if (Math.hypot(dx, dy) > 6) this.drag.moved = true
      if (this.scale > 1) {
        this.pan = this.clamp({ x: this.drag.pan.x + dx, y: this.drag.pan.y + dy }, this.scale)
      } else {
        // Follow the finger so a swipe feels connected; dragging down also fades the backdrop
        this.pan = Math.abs(dx) > Math.abs(dy) ? { x: dx, y: 0 } : { x: 0, y: Math.max(0, dy) }
        this.dialog.style.setProperty("--viewer-fade", String(1 - Math.min(Math.max(dy, 0) / 400, 0.6)))
      }
      this.apply(false)
    })

    const finish = (event) => {
      if (!this.pointers.has(event.pointerId)) return
      this.pointers.delete(event.pointerId)
      if (this.pinch) {
        if (this.pointers.size < 2) this.pinch = null
        if (this.scale <= 1.02) this.reset()
        return
      }
      if (!this.drag) return

      const drag = this.drag
      this.drag = null
      this.dialog.classList.remove("is-dragging")
      this.dialog.style.removeProperty("--viewer-fade")
      const dx = event.clientX - drag.x
      const dy = event.clientY - drag.y

      if (!drag.moved) {
        this.tap(event)
        return
      }
      if (this.scale > 1) return

      const swipe = classifySwipe({ dx, dy, ms: performance.now() - drag.time })
      if (swipe === "down") return this.close()
      // Reading right to left, the next image comes from the left: dragging right brings it in
      if (swipe === "right") return this.step(1)
      if (swipe === "left") return this.step(-1)
      this.pan = { x: 0, y: 0 }
      this.apply(true)
    }
    this.stage.addEventListener("pointerup", finish)
    this.stage.addEventListener("pointercancel", finish)

    this.stage.addEventListener("wheel", (event) => {
      event.preventDefault()
      if (this.scale === 1 && !this.zoomableScale()) return
      this.zoomTo(this.scale * Math.exp(-event.deltaY * 0.002), this.pointFrom(event), false)
    }, { passive: false })
  }

  // A click or tap on the picture zooms in (when there's more detail to see) or back out; on the dark
  // background it closes, or zooms out first if zoomed
  tap(event) {
    if (this.scale > 1) {
      this.reset()
      this.apply(true)
    } else if (!this.isOnImage(event)) {
      this.close()
    } else if (this.zoomableScale()) {
      this.zoomTo(this.zoomableScale(), this.pointFrom(event), true)
    }
  }

  isOnImage(event) {
    const rect = this.picture.getBoundingClientRect()
    return event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom
  }

  distance() {
    const [a, b] = [...this.pointers.values()]
    return Math.hypot(a.x - b.x, a.y - b.y) || 1
  }
}
