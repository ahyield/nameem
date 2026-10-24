import { describe, expect, it } from "vitest"
import { fitWithin, MAX_DIMENSION, MAX_UNTOUCHED_BYTES, needsResize, outputType, renamed } from "../../app/javascript/lib/image_prepare"

describe("fitWithin", () => {
  it("scales the long side down to the maximum, keeping the ratio", () => {
    expect(fitWithin(4032, 3024)).toEqual({ width: MAX_DIMENSION, height: 1500 })
    expect(fitWithin(3024, 4032)).toEqual({ width: 1500, height: MAX_DIMENSION })
  })

  it("never scales small images up", () => {
    expect(fitWithin(800, 600)).toEqual({ width: 800, height: 600 })
  })
})

describe("needsResize", () => {
  it("resizes large or heavy photos", () => {
    expect(needsResize({ type: "image/jpeg", size: 500_000, width: 4032, height: 3024 })).toBe(true)
    expect(needsResize({ type: "image/jpeg", size: MAX_UNTOUCHED_BYTES + 1, width: 1200, height: 900 })).toBe(true)
  })

  it("leaves small images and GIFs alone", () => {
    expect(needsResize({ type: "image/png", size: 200_000, width: 1200, height: 900 })).toBe(false)
    expect(needsResize({ type: "image/gif", size: 9_000_000, width: 4000, height: 3000 })).toBe(false)
  })
})

describe("output", () => {
  it("keeps PNG for transparency and turns the rest into JPEG", () => {
    expect(outputType("image/png")).toBe("image/png")
    expect(outputType("image/webp")).toBe("image/jpeg")
    expect(renamed("IMG_1234.HEIC", "image/jpeg")).toBe("IMG_1234.jpg")
    expect(renamed("diagram.png", "image/png")).toBe("diagram.png")
    expect(renamed(".png", "image/jpeg")).toBe("image.jpg")
  })
})
