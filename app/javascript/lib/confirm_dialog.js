// An in-page "are you sure?" in place of the browser's confirm box. Resolves true when confirmed.
// Options: confirmLabel, cancelLabel, and destructive (a red confirm button for actions that remove things).
export function confirmDialog(message, { confirmLabel = "تأكيد", cancelLabel = "إلغاء", destructive = false } = {}) {
  return new Promise((resolve) => {
    const dialog = document.createElement("dialog")
    dialog.className = "confirm-dialog w-[calc(100%-2rem)] max-w-sm rounded-2xl bg-raised p-6 text-gray-900 shadow-xl ring-1 ring-gray-900/5 outline-none backdrop:bg-gray-500/75 dark:backdrop:bg-black/60"
    dialog.setAttribute("dir", "rtl")
    dialog.setAttribute("aria-describedby", "confirm-dialog-message")

    const text = document.createElement("p")
    text.id = "confirm-dialog-message"
    text.className = "text-base leading-7 text-gray-900"
    text.textContent = message

    const actions = document.createElement("div")
    actions.className = "mt-6 flex justify-end gap-3"

    const confirm = document.createElement("button")
    confirm.type = "button"
    confirm.textContent = confirmLabel
    confirm.className = destructive
      ? "rounded-full bg-red-600 px-5 py-2 text-sm font-semibold text-white transition-[transform,background-color] duration-150 hover:bg-red-500 active:scale-[0.97] focus:outline-none focus-visible:ring-2 focus-visible:ring-red-500 focus-visible:ring-offset-2"
      : "rounded-full bg-gray-900 px-5 py-2 text-sm font-semibold text-surface transition-[transform,background-color] duration-150 hover:bg-gray-800 active:scale-[0.97] focus:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2"

    const cancel = document.createElement("button")
    cancel.type = "button"
    cancel.textContent = cancelLabel
    cancel.className = "rounded-full px-5 py-2 text-sm font-medium text-gray-600 transition-[transform,background-color] duration-150 hover:bg-gray-100 active:scale-[0.97] focus:outline-none focus-visible:ring-2 focus-visible:ring-orange-500"

    actions.append(cancel, confirm)
    dialog.append(text, actions)
    document.body.append(dialog)

    let answer = false
    confirm.addEventListener("click", () => { answer = true; dialog.close() })
    cancel.addEventListener("click", () => dialog.close())
    // Clicking the backdrop (the dialog element itself, outside its content) cancels
    dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close() })
    dialog.addEventListener("close", () => {
      dialog.remove()
      resolve(answer)
    })

    // Focus the dialog rather than a button, so Enter can't confirm by accident and no ring flashes on open
    dialog.tabIndex = -1
    dialog.showModal()
    dialog.focus()
  })
}

// Turbo's data-turbo-confirm goes through the same dialog. A submit button or form can set
// data-confirm-label, and data-confirm-destructive for a red button.
export function turboConfirm(message, element, submitter) {
  const source = submitter?.dataset.confirmLabel ? submitter : element
  return confirmDialog(message, {
    confirmLabel: source?.dataset.confirmLabel,
    destructive: (submitter || element)?.dataset.confirmDestructive !== undefined
  })
}
