// I am ashamed of it.
// needs hygine, but works for now.

import { DirectUpload } from "@rails/activestorage"
import { Controller } from "@hotwired/stimulus"
import Quill from "quill"

const Block = Quill.import("blots/block")
const BlockEmbed = Quill.import("blots/block/embed")

const Delta = Quill.import("delta")

var Clipboard = Quill.import("modules/clipboard")

class PlainClipboard extends Clipboard {
  // This is to prevent quill from styling the pasted text
  // with the same style as the editor.
  onPaste (e) {
    e.preventDefault()
    const range = this.quill.getSelection()
    const text = e.clipboardData.getData("text/plain")
    const delta = new Delta()
    .retain(range.index)
    .delete(range.length)
    .insert(text)
    const index = text.length + range.index
    const length = 0
    this.quill.updateContents(delta, "silent")
    this.quill.setSelection(index, length, "silent")
    this.quill.scrollIntoView()
  }
}

class ImageBlot extends BlockEmbed {
  static create(value) {
    const node = super.create()
    node.setAttribute("src", value.url)
    node.setAttribute("class", "py-4")
    return node
  }

  static value(node) {
    return {
      url: node.getAttribute("src")
    }
  }
}

ImageBlot.blotName = "customImage"
ImageBlot.tagName = "img"

Quill.register(ImageBlot)
Quill.register("modules/clipboard", PlainClipboard, true)

let editor = null
let change = new Delta()

export default class extends Controller {
  async connect() {
    var editorOptions = {
      debug: "error",
      placeholder: "إبدأ بالكتابة...",
      scrollingContainer: "html",
    }

    editor = new Quill(".editor-container", editorOptions)

    const toolTip = document.querySelector(".tooltip-controls")
    const sidebar = document.querySelector(".sidebar-controls")

    editor.format("direction", "rtl")
    editor.format("align", "right")

    const range = editor.getSelection()
    const rangeBounds = editor.getBounds(range)

    sidebar.style.display = "block"
    sidebar.style.marginTop = `${rangeBounds.top + 139}px`
    sidebar.style.left = `${ 8 + rangeBounds.left}px`

    editor.on(Quill.events.EDITOR_CHANGE, function(event, range) {
      if (event !== Quill.events.SELECTION_CHANGE) return
      if (range === null) return

     const rangeBounds = editor.getBounds(range.index, range.length)
     if (range.length === 0) {
       toolTip.style.display = "none"
       const [block] = editor.scroll.descendant(Block, range.index)

       if (block != null && block.domNode.firstChild instanceof HTMLBRElement) {
         sidebar.style.display = "block"
         sidebar.style.marginTop = `${rangeBounds.top + 139}px`
         sidebar.style.left = `${ 8 + rangeBounds.left}px`
       } else {
         sidebar.style.display = "none"
       }
     } else if (range.length > 0 ) {
       toolTip.style.display = "block"
       // position the tooltip
       toolTip.style.left = "0px"
       toolTip.style.marginRight = "-180px" // Hack to enable proper styling.)
       toolTip.style.marginLeft = `${rangeBounds.left - 100}px`
       toolTip.style.marginTop = `${rangeBounds.top + 90}px`
     }
    })

    if (!this.isNewArticle()) {
      const articleTitle = document.getElementById("article-title")
      const publishButton = document.querySelector(".btn-publish-disabled")
      const publichText = document.querySelector(".btn-publish-text")

      publichText.innerHTML = "حفظ ونشر"
      publishButton.classList.remove("btn-publish-disabled")

      const uuid = this.articleUuid()
      const slug = this.userSlug()
      const article = await this.fetchArticle(uuid, slug)
      sidebar.style.display = "none"
      articleTitle.value = article.title
      editor.setContents(article.content)
    }

    editor.on("text-change", (delta, oldContents, source) => {
      if (source == "api") {
          var uuid = this.articleUuid()
          var slug = this.userSlug()
          this.updateArticleContent(uuid, slug)
      } else if (source == "user") {
        const deleted = this.getImgUrls(editor.getContents().diff(oldContents))

        change = change.compose(delta)
        if(deleted.length >= 1) {
          const imageURL = deleted[0].url
          const signed_id = imageURL.split("/")[6]
          fetch(`/api/attachments/delete?image_url=${signed_id}`, { method: "DELETE" })
        }
      }
    })

    // wow
    setInterval(async () => {
      if (change.length() > 0) {
        if (this.isNewArticle()) {
          const data = await this.newArticle()
          this.drawUrl(data)
          this.activatePublishingButton(data.article.uuid, data.user.slug)
          await this.updateArticleContent(data.article.uuid, data.user.slug)
        } else {
          var uuid = this.articleUuid()
          var slug = this.userSlug()
          this.activatePublishingButton(uuid, slug)
          await this.updateArticleContent(uuid, slug)
        }
        change = new Delta()
      }
    }, 2 * 1000)
  }

  async fetchArticle(uuid, slug) {
    const response = await fetch(`/api/${slug}/${uuid}/edit`, { method: "GET" })

    const data = await response.json()
    return data
  }

  async newArticle() {
    const response = await fetch("/api/articles/new", { method: "GET" })

    const data = await response.json()
    return data
  }

  isNewArticle() {
    const path = window.location.pathname
    if (path === "/new-story") {
      return true
    } else {
      return false
    }
  }

  async upsertTitle(event) {
    const articleTitle = document.getElementById("article-title").value
    if (articleTitle === null) return

    if (this.isNewArticle()) {
      const data = await this.newArticle()
      this.drawUrl(data)
      this.activatePublishingButton(data.article.uuid, data.user.slug)
      await this.updateArticleTitle(data.article.uuid, data.user.slug)
      } else {
        var uuid = this.articleUuid()
        var slug = this.userSlug()
        this.activatePublishingButton(uuid, slug)
        await this.updateArticleTitle(uuid, slug)
      }
  }

  async updateArticleTitle(uuid, slug) {
    const articleTitle = document.getElementById("article-title").value

    const response = await fetch(`/api/${slug}/${uuid}/edit`, {
      method: "PUT",
      body: JSON.stringify({ article: { title: articleTitle, content: editor.getContents(), }}),
      headers: {
        "CONTENT-TYPE": "application/json",
      }
    })
    const article = await response.json()
    return article
  }

  async updateArticleContent(uuid, slug) {
    const response = await fetch(`/api/${slug}/${uuid}/edit`, {
      method: "PUT",
      body: JSON.stringify({ article: { content: editor.getContents(), }}),
      headers: {
        "CONTENT-TYPE": "application/json",
      }
    })
    const article = await response.json()
    return article
  }

  articleUuid() {
    const uuid = window.location.pathname.split("/")[2]
    return uuid
  }

  userSlug() {
    const slug = window.location.pathname.split("/")[1]
    return slug
  }

  drawUrl(data) {
    const url = window.location.origin + `/${data.user.slug}/${data.article.uuid}/edit`
    window.history.pushState(null, null, url)
  }

  activatePublishingButton(uuid, slug) {
    const btn = document.querySelector(".btn-publish-disabled")
    if(btn) {
      btn.classList.remove("btn-publish-disabled")
    }

    const form = document.getElementById("publish-form-btn")
    form.action = `/${slug}/publish_modal/${uuid}`
  }

  getImgUrls(delta) {
    return delta.ops.filter(i => i.insert && i.insert.customImage).map(i => i.insert.customImage)
  }

  toggleLink() {
    const toolTip = document.querySelector(".tooltip-controls")
    const linkTip = document.querySelector(".link-tip")

    const range = editor.getSelection()
    const rangeBounds = editor.getBounds(range.index, range.length)

    if(toolTip.style.display === "block") {
      toolTip.style.display = "none"
      linkTip.style.display = "block"
      linkTip.style.left = "0px"
      linkTip.style.width = "22%"
      linkTip.style.marginLeft = `${rangeBounds.left - 100}px`
      linkTip.style.marginTop = `${rangeBounds.top + 90}px`
      document.getElementById("link").focus()
    } else {
      toolTip.style.display = "block"
      linkTip.style.display = "none"
    }
  }

  toggleBold() {
    const range = editor.getSelection()
    const format = editor.getFormat(range)
    if (format.bold === undefined) {
      editor.format("bold", true)
    } else {
      editor.format("bold", false)
    }
  }

  toggleItalic() {
    const range = editor.getSelection()
    const format = editor.getFormat(range)
    if (format.italic === undefined) {
      editor.format("italic", true)
    } else {
      editor.format("italic", false)
    }
  }

  toggleQuote() {
    const range = editor.getSelection()
    const format = editor.getFormat(range)
    if (format.blockquote === undefined) {
      editor.format("blockquote", true)
    } else {
      editor.format("blockquote", false)
    }
  }

  toggleHead1() {
    const range = editor.getSelection()
    const format = editor.getFormat(range)
    if (format.header === undefined) {
      editor.format("header", 1)
    } else {
      editor.format("header", false)
    }
  }

  toggleHead2() {
    const range = editor.getSelection()
    const format = editor.getFormat(range)
    if (format.header === undefined) {
      editor.format("header", 2)
    } else {
      editor.format("header", false)
    }
  }

  closeTips(event) {
    const linkTip = document.querySelector(".link-tip")
    const toolTip = document.querySelector(".tooltip-controls")
    document.getElementById("link").value = ""

    linkTip.style.display = "none"
    toolTip.style.display = "none"
  }

  enterLinkTip(event) {
    const linkTip = document.querySelector(".link-tip")
    const toolTip = document.querySelector(".tooltip-controls")
    var linkValue = document.getElementById("link").value

    document.getElementById("link").addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        editor.format("link", linkValue)
        document.getElementById("link").value = ""

        linkTip.style.display = "none"
        toolTip.style.display = "none"
      }
    })
  }

  hideLinkTip(event) {
    const linkTip = document.querySelector(".link-tip")
    var linkValue = document.getElementById("link").value

    const range = editor.getSelection()

    if (range && range.length === 0) {
      linkTip.style.display = "none"
    }

    // no clue how this works
    if(this.element === event.target || this.element.contains(event.target)) return
    if(linkValue) {
      editor.format("link", linkValue)
      document.getElementById("link").value = ""
    }
    linkTip.style.display = "none"
    this.hideToolTip(event)
  }

  hideToolTip(event) {
    if(this.element === event.target || this.element.contains(event.target)) return

    const toolTip = document.querySelector(".tooltip-controls")
    toolTip.style.display = "none"
  }

  imageUpload(event) {
    const input = document.createElement("input")
    input.type = "file"
    input.accept = "image/png, image/jpeg"

    input.onchange = _ => {
      const range = editor.getSelection(true)
      const file =   input.files[0]

      const baseURL = window.location.origin
      const url = `${baseURL}/rails/active_storage/direct_uploads`
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) {
          alert("Uploading failed!")
        } else {
          editor.insertEmbed(range.index, "customImage", {
            url: `${baseURL}/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`,
          }, Quill.sources.USER)
          editor.setSelection(range.index + 1, Quill.sources.SILENT)
          const sidebar = document.querySelector(".sidebar-controls")
          sidebar.style.display = "none"
        }
      })
    }
    input.click()
  }
}
