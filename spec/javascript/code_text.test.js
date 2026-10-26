// @vitest-environment jsdom
import { describe, expect, it } from "vitest"
import { codeText } from "../../app/javascript/lib/code_text"

function pre(html) {
  const element = document.createElement("pre")
  element.innerHTML = html
  return element
}

describe("codeText", () => {
  it("turns Lexical's <br> lines into newlines and keeps indentation", () => {
    const block = pre("<span>def hi</span><br><span>  puts \"مرحبا\"</span><br><span>end</span>")
    expect(codeText(block)).toBe("def hi\n  puts \"مرحبا\"\nend")
  })

  it("leaves out the copy button", () => {
    const block = pre("<span>ls -la</span><button data-code-copy-ignore>نسخ</button>")
    expect(codeText(block)).toBe("ls -la")
  })

  it("drops a trailing line break", () => {
    expect(codeText(pre("<span>x = 1</span><br>"))).toBe("x = 1")
  })
})
