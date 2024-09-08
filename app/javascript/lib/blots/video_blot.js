import { BaseBlot } from "lib/blots/base_blot"

export class VideoBlot extends BaseBlot {
  static create(url) {
    const node = super.create()
    node.setAttribute("src", url)
    node.setAttribute("class", "py-4")
    node.setAttribute("frameborder", "0")
    node.setAttribute("allowfullscreen", true)
    return node
  }

  static formats(node) {
    const format = {}
    if (node.hasAttribute("height")) {
      format.height = node.getAttribute("height")
    }
    if (node.hasAttribute("width")) {
      format.width = node.getAttribute("width")
    }
    return format
  }

  static value(node) {
    return node.getAttribute("src")
  }

  format(name, value) {
    if (name === "height" || name === "width") {
      if (value) {
        this.domNode.setAttribute(name, value)
      } else {
        this.domNode.removeAttribute(name, value)
      }
    } else {
      super.format(name, value)
    }
  }
}

VideoBlot.blotName = "video"
VideoBlot.tagName = "iframe"

export default VideoBlot
