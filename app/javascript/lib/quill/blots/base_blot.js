import Quill from "quill"

const BlockEmbed = Quill.import("blots/block/embed")

export class BaseBlot extends BlockEmbed {
  static create(value) {
    const node = super.create(value)
    return node
  }

  static value(node) {
    return {
      node
    }
  }
}

BaseBlot.blotName = "base"
BaseBlot.tagName = "div"

export default BaseBlot
