import { $getNodeByKey, DecoratorNode } from "lexical"

const CAPTION_LIMIT = 200

export class ImageNode extends DecoratorNode {
  __src
  __alt
  __caption
  // True while the image shows a local preview and is still being uploaded; never saved
  __uploading

  static getType() {
    return "image"
  }

  static clone(node) {
    return new ImageNode(node.__src, node.__alt, node.__uploading, node.__caption, node.__key)
  }

  constructor(src, alt, uploading, caption, key) {
    super(key)
    this.__src = src
    this.__alt = alt || ""
    this.__uploading = Boolean(uploading)
    this.__caption = caption || ""
  }

  setSrc(src) {
    const writable = this.getWritable()
    writable.__src = src
    writable.__uploading = false
  }

  isUploading() {
    return this.getLatest().__uploading
  }

  getCaption() {
    return this.getLatest().__caption
  }

  setCaption(caption) {
    this.getWritable().__caption = caption.slice(0, CAPTION_LIMIT)
  }

  static importJSON(serializedNode) {
    return $createImageNode({ src: serializedNode.src, alt: serializedNode.alt, caption: serializedNode.caption })
  }

  exportJSON() {
    return {
      type: "image",
      version: 2,
      src: this.__src,
      alt: this.__alt,
      caption: this.__caption,
    }
  }

  createDOM(_config, editor) {
    const figure = document.createElement("figure")
    figure.className = "editor-image-wrapper"
    figure.classList.toggle("is-uploading", this.__uploading)

    const loader = document.createElement("div")
    loader.className = "editor-image-loader"
    const spinner = document.createElement("div")
    spinner.className = "editor-image-spinner"
    loader.appendChild(spinner)

    const img = document.createElement("img")
    img.src = this.__src
    img.alt = this.__alt
    img.className = "editor-image"
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
    figure.appendChild(this.createCaptionField(editor))
    return figure
  }

  // An ordinary text field under the image, outside the editable text, so typing in it never edits the article
  createCaptionField(editor) {
    const caption = document.createElement("figcaption")
    caption.contentEditable = "false"
    caption.className = "editor-image-caption"
    caption.classList.toggle("is-empty", this.__caption === "")

    const input = document.createElement("input")
    input.type = "text"
    input.dir = "auto"
    input.maxLength = CAPTION_LIMIT
    input.placeholder = "أضف تعليقاً على الصورة (اختياري)"
    input.setAttribute("aria-label", "تعليق الصورة")
    input.value = this.__caption

    const key = this.__key
    input.addEventListener("input", () => {
      caption.classList.toggle("is-empty", input.value === "")
      editor.update(() => $getNodeByKey(key)?.setCaption(input.value))
    })
    for (const type of ["keydown", "keyup", "keypress", "beforeinput", "paste", "cut", "copy"]) {
      input.addEventListener(type, (event) => {
        event.stopPropagation()
        if (type === "keydown" && event.key === "Enter") event.preventDefault()
      })
    }

    caption.appendChild(input)
    return caption
  }

  // Swaps the source in place once an upload finishes, instead of rebuilding the figure
  updateDOM(prevNode, dom) {
    dom.classList.toggle("is-uploading", this.__uploading)
    const img = dom.querySelector("img")
    if (img && prevNode.__src !== this.__src) img.src = this.__src
    const input = dom.querySelector(".editor-image-caption input")
    if (input && input.value !== this.__caption) input.value = this.__caption
    return false
  }

  exportDOM() {
    const figure = document.createElement("figure")
    const img = document.createElement("img")
    img.src = this.__src
    img.alt = this.__alt || this.__caption
    figure.appendChild(img)
    if (this.__caption) {
      const caption = document.createElement("figcaption")
      caption.textContent = this.__caption
      figure.appendChild(caption)
    }
    return { element: figure }
  }

  static importDOM() {
    return {
      img: () => ({
        conversion: convertImageElement,
        priority: 0,
      }),
      // The caption is read with its image; on its own it shouldn't become a paragraph
      figcaption: () => ({
        conversion: () => ({ node: null, forChild: () => null }),
        priority: 1,
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
  const caption = domNode.closest("figure")?.querySelector("figcaption")?.textContent?.trim() || ""
  const alt = domNode.getAttribute("alt") || ""
  return { node: $createImageNode({ src, alt: alt === caption ? "" : alt, caption }) }
}

export function $createImageNode({ src, alt, caption = "", uploading = false }) {
  return new ImageNode(src, alt, uploading, caption)
}

export function $isImageNode(node) {
  return node instanceof ImageNode
}
