// A page view becomes a read once the reader has stayed READ_SECONDS on the article and scrolled
// through READ_DEPTH of it
export const READ_SECONDS = 30
export const READ_DEPTH = 0.6

// How much of the element has scrolled into view, from 0 to 1, given its bounding rect and the viewport height
export function scrolledDepth(rect, viewportHeight) {
  if (!rect || rect.height <= 0) return 0

  const seen = (viewportHeight - rect.top) / rect.height
  return Math.min(Math.max(seen, 0), 1)
}

export function isRead({ elapsedSeconds, depth }) {
  return elapsedSeconds >= READ_SECONDS && depth >= READ_DEPTH
}
