import { describe, expect, it } from "vitest"
import { validateTweetUrl, validateVideoUrl } from "../../app/javascript/lib/utils/validation_utils.js"

describe("validateVideoUrl", () => {
  it.each([
    ["https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s", "https://www.youtube.com/embed/dQw4w9WgXcQ"],
    ["https://youtu.be/dQw4w9WgXcQ?si=abc", "https://www.youtube.com/embed/dQw4w9WgXcQ"],
    ["https://m.youtube.com/shorts/dQw4w9WgXcQ", "https://www.youtube.com/embed/dQw4w9WgXcQ"],
    ["https://vimeo.com/76979871", "https://player.vimeo.com/video/76979871"],
    ["https://vimeo.com/76979871/abc123def", "https://player.vimeo.com/video/76979871?h=abc123def"],
    ["https://player.vimeo.com/video/76979871?h=abc123", "https://player.vimeo.com/video/76979871?h=abc123"]
  ])("turns %s into a canonical embed URL", (input, expected) => {
    expect(validateVideoUrl(input)).toBe(expected)
  })

  it.each([
    ["https://123.evil.com/vimeo.com"],
    ["https://evil.com/youtube.com/watch?v=dQw4w9WgXcQ"],
    ["https://youtube.com.evil.com/watch?v=dQw4w9WgXcQ"],
    ["javascript:alert(1)//youtube.com"],
    ["not a url"]
  ])("rejects %s", (input) => {
    expect(validateVideoUrl(input)).toBeNull()
  })
})

describe("validateTweetUrl", () => {
  it.each([
    ["https://x.com/jack/status/20", "20"],
    ["https://twitter.com/jack/status/1234567890?s=20", "1234567890"]
  ])("extracts the tweet ID from %s", (input, expected) => {
    expect(validateTweetUrl(input)).toBe(expected)
  })

  it.each([
    ["https://evil.com/x.com/a/status/1"],
    ["https://x.com/jack"]
  ])("rejects %s", (input) => {
    expect(validateTweetUrl(input)).toBeNull()
  })
})
