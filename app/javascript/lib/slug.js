// The words of an article's address, made the same way as on the server (Permalinkable.slug_from): no Arabic
// short vowels or tatweel, lowercase, anything that isn't a letter or digit becomes a dash, shortened at a word
const ARABIC_MARKS = /[ؐ-ًؚ-ٰٟۖ-ۭـ]/gu
export const SLUG_LENGTH = 60

export function slugify(text) {
  const words = String(text ?? "")
    .normalize("NFKC")
    .replace(ARABIC_MARKS, "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, "-")
    .replace(/^-|-$/g, "")
  if (words.length <= SLUG_LENGTH) return words

  const cut = words.slice(0, SLUG_LENGTH + 1)
  const lastDash = cut.lastIndexOf("-")
  return lastDash > 0 ? cut.slice(0, lastDash) : words.slice(0, SLUG_LENGTH)
}
