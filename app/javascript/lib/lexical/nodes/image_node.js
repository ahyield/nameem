import { DecoratorNode } from "lexical"

export class ImageNode extends DecoratorNode {
  __src
  __alt

  static getType() {
    return "image"
  }

  static clone(node) {
    return new ImageNode(node.__src, node.__alt, node.__key)
  }

  constructor(src, alt, key) {
    super(key)
    this.__src = src
    this.__alt = alt || ""
  }

  static importJSON(serializedNode) {
    return $createImageNode({ src: serializedNode.src, alt: serializedNode.alt })
  }

  exportJSON() {
    return {
      type: "image",
      version: 1,
      src: this.__src,
      alt: this.__alt,
    }
  }

  createDOM() {
    const figure = document.createElement("figure")
    figure.className = "editor-image-wrapper"

    const loader = document.createElement("div")
    loader.className = "editor-image-loader"
    const spinner = document.createElement("div")
    spinner.className = "editor-image-spinner"
    loader.appendChild(spinner)

    const img = document.createElement("img")
    img.src = this.__src
    img.alt = this.__alt
    img.className = "py-4 editor-image"
    img.style.display = "none"

    img.addEventListener("load", () => {
      loader.remove()
      img.style.display = "block"
    })

    img.addEventListener("error", () => {
      spinner.remove()
      loader.textContent = "فشل تحميل الصورة"
      loader.classList.add("editor-image-error")
    })

    figure.appendChild(loader)
    figure.appendChild(img)
    return figure
  }

  updateDOM() {
    return false
  }

  exportDOM() {
    const figure = document.createElement("figure")
    const img = document.createElement("img")
    img.src = this.__src
    img.alt = this.__alt
    img.className = "py-4"
    figure.appendChild(img)
    return { element: figure }
  }

  static importDOM() {
    return {
      img: () => ({
        conversion: convertImageElement,
        priority: 0,
      }),
    }
  }

  decorate() {
    return null
  }
}

function convertImageElement(domNode) {
  const src = domNode.getAttribute("src")
  if (!src) return null
  const alt = domNode.getAttribute("alt") || ""
  return { node: $createImageNode({ src, alt }) }
}

export function $createImageNode({ src, alt }) {
  return new ImageNode(src, alt)
}

export function $isImageNode(node) {
  return node instanceof ImageNode
}
