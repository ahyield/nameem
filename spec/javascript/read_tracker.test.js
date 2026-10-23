import { describe, expect, it } from "vitest"
import { isRead, READ_DEPTH, READ_SECONDS, scrolledDepth } from "../../app/javascript/lib/read_tracker"

describe("scrolledDepth", () => {
  it("is 0 before the article reaches the viewport", () => {
    expect(scrolledDepth({ top: 900, height: 2000 }, 800)).toBe(0)
  })

  it("grows as the article scrolls through the viewport", () => {
    expect(scrolledDepth({ top: -400, height: 2000 }, 800)).toBeCloseTo(0.6)
  })

  it("caps at 1 once the end is in view, and handles empty elements", () => {
    expect(scrolledDepth({ top: -3000, height: 2000 }, 800)).toBe(1)
    expect(scrolledDepth({ top: 0, height: 0 }, 800)).toBe(0)
    expect(scrolledDepth(null, 800)).toBe(0)
  })
})

describe("isRead", () => {
  it("needs both enough time and enough scrolling", () => {
    expect(isRead({ elapsedSeconds: READ_SECONDS, depth: READ_DEPTH })).toBe(true)
    expect(isRead({ elapsedSeconds: READ_SECONDS - 1, depth: 1 })).toBe(false)
    expect(isRead({ elapsedSeconds: 600, depth: READ_DEPTH - 0.01 })).toBe(false)
  })
})
