import { describe, expect, it } from "vitest"
import { SLUG_LENGTH, slugify } from "../../app/javascript/lib/slug"

describe("slugify", () => {
  it("keeps Arabic words without their short vowels, joined by dashes", () => {
    expect(slugify("رحلةٌ إلى نيو-يورك!")).toBe("رحلة-إلى-نيو-يورك")
  })

  it("lowercases Latin words and drops punctuation", () => {
    expect(slugify("Hello, World — مرحباً")).toBe("hello-world-مرحبا")
  })

  it("is empty for nothing but punctuation", () => {
    expect(slugify("...")).toBe("")
    expect(slugify(null)).toBe("")
  })

  it("shortens long text at a word, or mid-word when there's no other choice", () => {
    const slug = slugify("كلمة ".repeat(30))
    expect(slug.length).toBeLessThanOrEqual(SLUG_LENGTH)
    expect(slug.endsWith("كلمة")).toBe(true)
    expect(slugify("a".repeat(80))).toHaveLength(SLUG_LENGTH)
  })
})
