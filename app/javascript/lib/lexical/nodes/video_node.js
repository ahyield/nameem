import { DecoratorNode } from "lexical"

export class VideoNode extends DecoratorNode {
  __src

  static getType() {
    return "video"
  }

  static clone(node) {
    return new VideoNode(node.__src, node.__key)
  }

  constructor(src, key) {
    super(key)
    this.__src = src
  }

  static importJSON(serializedNode) {
    return $createVideoNode(serializedNode.src)
  }

  exportJSON() {
    return {
      type: "video",
      version: 1,
      src: this.__src,
    }
  }

  createDOM() {
    const figure = document.createElement("figure")
    const iframe = document.createElement("iframe")
    iframe.src = this.__src
    iframe.frameBorder = "0"
    iframe.allowFullscreen = true
    iframe.className = "py-4"
    iframe.width = "740"
    iframe.height = "360"
    figure.appendChild(iframe)
    return figure
  }

  updateDOM() {
    return false
  }

  exportDOM() {
    const figure = document.createElement("figure")
    const iframe = document.createElement("iframe")
    iframe.src = this.__src
    iframe.frameBorder = "0"
    iframe.allowFullscreen = true
    iframe.width = "740"
    iframe.height = "360"
    figure.appendChild(iframe)
    return { element: figure }
  }

  static importDOM() {
    return {
      iframe: () => ({
        conversion: convertIframeElement,
        priority: 0,
      }),
    }
  }

  decorate() {
    return null
  }
}

function convertIframeElement(domNode) {
  const src = domNode.getAttribute("src")
  if (!src) return null
  return { node: $createVideoNode(src) }
}

export function $createVideoNode(src) {
  return new VideoNode(src)
}

export function $isVideoNode(node) {
  return node instanceof VideoNode
}
