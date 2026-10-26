// Pure maths for the image viewer, kept apart from the DOM so it can be tested

export const MIN_SCALE = 1
export const MAX_SCALE = 4
export const TAP_ZOOM = 2.5

// Next or previous image, wrapping around
export function nextIndex(index, step, count) {
  if (count <= 0) return 0
  return ((index + step) % count + count) % count
}

// Arrow keys follow the page's reading direction: in RTL, ← moves forward
export function stepForKey(key, rtl = true) {
  if (key === "ArrowLeft") return rtl ? 1 : -1
  if (key === "ArrowRight") return rtl ? -1 : 1
  return 0
}

export function clampScale(scale) {
  return Math.min(MAX_SCALE, Math.max(MIN_SCALE, scale))
}

// Keeps a zoomed image covering the viewport: it can't be dragged so far that empty space shows on a side
// it overflows. `size` is the image's on-screen size at scale 1, centred in `viewport`.
export function clampPan({ x, y }, scale, size, viewport) {
  const maxX = Math.max(0, (size.width * scale - viewport.width) / 2)
  const maxY = Math.max(0, (size.height * scale - viewport.height) / 2)
  return { x: Math.min(maxX, Math.max(-maxX, x)), y: Math.min(maxY, Math.max(-maxY, y)) }
}

// Zooms so the point under the finger or cursor stays put. `point` is relative to the viewport centre.
export function zoomAround(point, pan, fromScale, toScale) {
  const ratio = toScale / fromScale
  return { x: point.x - (point.x - pan.x) * ratio, y: point.y - (point.y - pan.y) * ratio }
}

// What a finished one-finger drag at scale 1 meant: change image, close, or nothing
export function classifySwipe({ dx, dy, ms }) {
  const distance = Math.hypot(dx, dy)
  const fast = distance / Math.max(ms, 1) > 0.5
  if (Math.abs(dx) > Math.abs(dy)) {
    if (Math.abs(dx) > 80 || (fast && Math.abs(dx) > 30)) return dx < 0 ? "left" : "right"
  } else if (dy > 120 || (fast && dy > 40)) {
    return "down"
  }
  return null
}
