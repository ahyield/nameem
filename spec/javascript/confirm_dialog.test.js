// @vitest-environment jsdom
import { afterEach, beforeAll, describe, expect, it } from "vitest"
import { confirmDialog, turboConfirm } from "../../app/javascript/lib/confirm_dialog"

beforeAll(() => {
  // jsdom doesn't implement modal dialogs
  HTMLDialogElement.prototype.showModal ||= function () { this.open = true }
  HTMLDialogElement.prototype.close ||= function () { this.open = false; this.dispatchEvent(new Event("close")) }
})

afterEach(() => { document.body.innerHTML = "" })

const buttons = () => [...document.querySelectorAll("dialog button")]
const button = (label) => buttons().find((b) => b.textContent === label)

describe("confirmDialog", () => {
  it("resolves true when confirmed and removes itself", async () => {
    const answer = confirmDialog("متأكد؟", { confirmLabel: "نعم" })
    expect(document.querySelector("dialog").textContent).toContain("متأكد؟")

    button("نعم").click()

    await expect(answer).resolves.toBe(true)
    expect(document.querySelector("dialog")).toBeNull()
  })

  it("resolves false when cancelled or dismissed by the backdrop", async () => {
    const cancelled = confirmDialog("متأكد؟")
    button("إلغاء").click()
    await expect(cancelled).resolves.toBe(false)

    const dismissed = confirmDialog("متأكد؟")
    document.querySelector("dialog").click()
    await expect(dismissed).resolves.toBe(false)
  })

  it("uses a red button for destructive actions", () => {
    confirmDialog("احذف؟", { confirmLabel: "حذف", destructive: true })
    expect(button("حذف").className).toContain("bg-red-600")
  })
})

describe("turboConfirm", () => {
  it("takes the label and destructive flag from the submit button", () => {
    const submitter = document.createElement("button")
    submitter.dataset.confirmLabel = "حذف"
    submitter.dataset.confirmDestructive = "true"

    turboConfirm("احذف؟", document.createElement("form"), submitter)

    expect(button("حذف").className).toContain("bg-red-600")
  })

  it("falls back to the default label", () => {
    turboConfirm("متأكد؟", document.createElement("form"))
    expect(button("تأكيد").className).toContain("bg-gray-900")
  })
})
