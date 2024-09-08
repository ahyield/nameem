import { BaseBlot } from "lib/quill/blots/base_blot"

export class ImageBlot extends BaseBlot {
  static create(value) {
    const node = super.create(value)
    node.setAttribute("src", value.url)
    node.setAttribute("class", "py-4")
    return node
  }

  static value(node) {
    return {
      url: node.getAttribute("src"),
    }
  }
}

ImageBlot.blotName = "customImage"
ImageBlot.tagName = "img"

export default ImageBlot
