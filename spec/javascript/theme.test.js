import { describe, expect, it } from "vitest"
import { JSDOM } from "jsdom"
import { applyTheme, followSystemTheme, isDark, THEME_COLORS } from "../../app/javascript/lib/theme"

function page(theme = "system") {
  const { document } = new JSDOM(`<html data-theme="${theme}"><head><meta name="theme-color" content="#ffffff"></head></html>`).window
  return document.documentElement
}

describe("isDark", () => {
  it("is dark when chosen, or when following a dark device", () => {
    expect(isDark("dark", false)).toBe(true)
    expect(isDark("system", true)).toBe(true)
    expect(isDark("system", false)).toBe(false)
    expect(isDark("light", true)).toBe(false)
  })
})

describe("applyTheme", () => {
  it("sets the choice, the dark class and the browser bar colour", () => {
    const root = page()

    applyTheme(root, "dark", false)
    expect(root.dataset.theme).toBe("dark")
    expect(root.classList.contains("dark")).toBe(true)
    expect(root.querySelector("meta[name='theme-color']").content).toBe(THEME_COLORS.dark)

    applyTheme(root, "light", true)
    expect(root.classList.contains("dark")).toBe(false)
    expect(root.querySelector("meta[name='theme-color']").content).toBe(THEME_COLORS.light)
  })
})

describe("followSystemTheme", () => {
  function media() {
    const listeners = []
    return { addEventListener: (_, fn) => listeners.push(fn), change: (matches) => listeners.forEach((fn) => fn({ matches })) }
  }

  it("follows the device only while the reader is on automatic", () => {
    const root = page("system")
    const device = media()
    followSystemTheme(root, device)

    device.change(true)
    expect(root.classList.contains("dark")).toBe(true)

    applyTheme(root, "light", true)
    device.change(true)
    expect(root.classList.contains("dark")).toBe(false)
  })
})
