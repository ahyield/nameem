import { BaseBlot } from "lib/quill/blots/base_blot"

export class DividerBlot extends BaseBlot {
  static create(value) {
    const node = super.create(value)
    node.setAttribute("class", "editor-hr")
    return node
  }
}

DividerBlot.blotName = "divider"
DividerBlot.tagName = "hr"

export default DividerBlot
