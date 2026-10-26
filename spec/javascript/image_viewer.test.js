import { describe, expect, it } from "vitest"
import { clampPan, clampScale, classifySwipe, MAX_SCALE, nextIndex, stepForKey, zoomAround } from "../../app/javascript/lib/image_viewer"

describe("nextIndex", () => {
  it("wraps around both ways", () => {
    expect(nextIndex(4, 1, 5)).toBe(0)
    expect(nextIndex(0, -1, 5)).toBe(4)
    expect(nextIndex(2, 1, 5)).toBe(3)
    expect(nextIndex(0, 1, 0)).toBe(0)
  })
})

describe("stepForKey", () => {
  it("moves forward with ← in RTL and with → in LTR", () => {
    expect(stepForKey("ArrowLeft")).toBe(1)
    expect(stepForKey("ArrowRight")).toBe(-1)
    expect(stepForKey("ArrowRight", false)).toBe(1)
    expect(stepForKey("Enter")).toBe(0)
  })
})

describe("clampScale", () => {
  it("keeps zoom between 1× and the maximum", () => {
    expect(clampScale(0.5)).toBe(1)
    expect(clampScale(10)).toBe(MAX_SCALE)
    expect(clampScale(2)).toBe(2)
  })
})

describe("clampPan", () => {
  const size = { width: 400, height: 300 }
  const viewport = { width: 400, height: 800 }

  it("allows panning only as far as the zoomed image overflows", () => {
    expect(clampPan({ x: 500, y: 500 }, 2, size, viewport)).toEqual({ x: 200, y: 0 })
    expect(clampPan({ x: -500, y: 0 }, 2, size, viewport)).toEqual({ x: -200, y: 0 })
  })

  it("keeps an unzoomed image centred", () => {
    expect(clampPan({ x: 50, y: 50 }, 1, size, viewport)).toEqual({ x: 0, y: 0 })
  })
})

describe("zoomAround", () => {
  it("keeps the point under the cursor in place", () => {
    const pan = zoomAround({ x: 100, y: 50 }, { x: 0, y: 0 }, 1, 2)
    expect(pan).toEqual({ x: -100, y: -50 })
    // the content point that was under the cursor is still under it: (100 - pan) / scale stays 100
    expect((100 - pan.x) / 2).toBe(100)
  })
})

describe("classifySwipe", () => {
  it("reads long or quick horizontal drags as changing image", () => {
    expect(classifySwipe({ dx: -120, dy: 10, ms: 400 })).toBe("left")
    expect(classifySwipe({ dx: 40, dy: 5, ms: 50 })).toBe("right")
  })

  it("reads a drag down as closing", () => {
    expect(classifySwipe({ dx: 10, dy: 150, ms: 400 })).toBe("down")
  })

  it("ignores small movements", () => {
    expect(classifySwipe({ dx: 20, dy: 10, ms: 400 })).toBeNull()
  })
})
