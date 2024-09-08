import Quill from "quill"

export const getEditorOptions = () => ({
  // This ignores the bullet/list keystroke.
  modules: {
    keyboard: {
      bindings: {
        "list autofill": {
          prefix: /^\s*()$/
        }
      }
    }
  },
  debug: "error",
  placeholder: "إبدأ بالكتابة...",
  scrollingContainer: "html",
})

export const setupQuill = (containerSelector) => {
  const editor = new Quill(containerSelector, getEditorOptions())
  editor.format("direction", "rtl")
  editor.format("align", "right")
  return editor
}
