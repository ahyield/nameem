import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import {
  $getRoot,
  $getSelection,
  $isRangeSelection,
  $createRangeSelection,
  $setSelection,
  $createParagraphNode,
  $insertNodes,
  FORMAT_TEXT_COMMAND,
  SELECTION_CHANGE_COMMAND,
  COMMAND_PRIORITY_LOW,
} from "lexical"
import { $setBlocksType } from "@lexical/selection"
import { $createHeadingNode, $createQuoteNode } from "@lexical/rich-text"
import { $generateHtmlFromNodes, $generateNodesFromDOM } from "@lexical/html"
import { $toggleLink } from "@lexical/link"

import { createNamoemEditor } from "lib/lexical/editor_config"
import { ImageNode, $createImageNode } from "lib/lexical/nodes/image_node"
import { $createVideoNode } from "lib/lexical/nodes/video_node"
import { TweetNode, $createTweetNode } from "lib/lexical/nodes/tweet_node"
import { $createDividerNode } from "lib/lexical/nodes/divider_node"
import { validateVideoUrl, validateTweetUrl } from "lib/utils/validation_utils"
import { createArticle, fetchArticle, saveArticle } from "lib/api/article_api"
import { isNewArticle, articleUuid, userSlug, drawUrl } from "lib/api/helpers/url_helpers"

export default class extends Controller {
  connect() {
    const container = this.element.querySelector(".editor-container")
    this.editor = createNamoemEditor(container)
    this.dirty = false
    this.saving = false
    this.titleDebounceTimer = null

    // RTL direction on root
    this.editor.update(() => {
      const root = $getRoot()
      if (root.getChildrenSize() === 0) {
        const paragraph = $createParagraphNode()
        root.append(paragraph)
        paragraph.select()
      }
    })

    const rootElement = this.editor.getRootElement()
    if (rootElement) {
      rootElement.dir = "rtl"
      rootElement.classList.add("editor-empty")
      rootElement.style.textAlign = "right"
    }

    // Selection change → toolbar positioning
    this.editor.registerCommand(
      SELECTION_CHANGE_COMMAND,
      () => {
        this.updateToolbar()
        return false
      },
      COMMAND_PRIORITY_LOW,
    )

    // Track dirty state + empty state for placeholder
    this.editor.registerUpdateListener(({ dirtyElements, dirtyLeaves, editorState }) => {
      if (dirtyElements.size > 0 || dirtyLeaves.size > 0) {
        this.dirty = true
      }

      // Toggle placeholder class
      editorState.read(() => {
        const root = $getRoot()
        const isEmpty = root.getTextContent().trim() === "" && root.getChildrenSize() <= 1
        const rootEl = this.editor.getRootElement()
        if (rootEl) {
          rootEl.classList.toggle("editor-empty", isEmpty)
        }
      })
    })

    // Track image deletions
    this.editor.registerMutationListener(ImageNode, (mutations) => {
      for (const [, mutation] of mutations) {
        if (mutation === "destroyed") {
          // We can't access the node after destruction, but we track via the DOM
          // The image cleanup will happen via the auto-save cycle
        }
      }
    })

    // Hydrate tweets when inserted into editor
    this.editor.registerMutationListener(TweetNode, (mutations) => {
      for (const [nodeKey, mutation] of mutations) {
        if (mutation === "created") {
          const element = this.editor.getElementByKey(nodeKey)
          if (element && window.twttr?.widgets) {
            const tweetId = element.dataset.tweetId
            if (tweetId) {
              twttr.widgets.createTweet(tweetId, element)
            }
          }
        }
      }
    })

    // Reposition toolbar when images finish loading (they shift content down)
    // Defer to next frame so image is visible and layout is recalculated
    container.addEventListener("load", (e) => {
      if (e.target.tagName === "IMG") {
        requestAnimationFrame(() => this.updateToolbar())
      }
    }, true)

    // Load existing article if editing
    if (!isNewArticle()) {
      this.loadArticle()
    } else {
      this.showControlsAtCaret()
    }

    // Auto-save every 2 seconds
    this.autoSaveInterval = setInterval(() => this.autoSave(), 2000)
  }

  disconnect() {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval)
    }
    if (this.titleDebounceTimer) {
      clearTimeout(this.titleDebounceTimer)
    }
  }

  async loadArticle() {
    const uuid = articleUuid()
    const slug = userSlug()

    const articleTitle = document.getElementById("article-title")
    const publishButton = document.querySelector(".btn-publish-disabled")
    const publishText = document.querySelector(".btn-publish-text")

    if (publishText) publishText.innerHTML = "حفظ ونشر"
    if (publishButton) publishButton.classList.remove("btn-publish-disabled")

    try {
      const article = await fetchArticle(uuid, slug)
      if (articleTitle) articleTitle.value = article.title

      // Hide + controls when loading existing content
      const controls = document.querySelector(".show-controls")
      if (controls) controls.style.display = "none"

      // Load content into editor
      if (article.content && article.content.root) {
        // Lexical JSON format
        const editorState = this.editor.parseEditorState(article.content)
        this.editor.setEditorState(editorState)
      } else if (article.content_html) {
        // Migrated HTML format
        this.editor.update(() => {
          const parser = new DOMParser()
          const dom = parser.parseFromString(article.content_html, "text/html")
          const nodes = $generateNodesFromDOM(this.editor, dom)
          const root = $getRoot()
          root.clear()
          root.select()
          $insertNodes(nodes)
        })
      } else if (article.content && article.content.ops) {
        // Legacy Quill Delta — should not happen after migration, but fallback
        console.warn("Article has Quill Delta content. Run migrate_quill_to_html rake task.")
      }

      this.dirty = false
    } catch (error) {
      console.error("Failed to load article:", error)
      const statusEl = document.getElementById("save-status")
      if (statusEl) statusEl.textContent = "فشل تحميل المقال"
    }
  }

  async autoSave() {
    if (!this.dirty || this.saving) return
    this.saving = true

    const statusEl = document.getElementById("save-status")
    if (statusEl) statusEl.textContent = "جاري الحفظ..."

    try {
      let uuid, slug

      if (isNewArticle()) {
        const data = await createArticle()
        drawUrl(data)
        this.activatePublishingButton(data.article.uuid, data.user.slug)
        uuid = data.article.uuid
        slug = data.user.slug
      } else {
        uuid = articleUuid()
        slug = userSlug()
        this.activatePublishingButton(uuid, slug)
      }

      const editorState = this.editor.getEditorState()
      const content = editorState.toJSON()
      let contentHtml = ""
      editorState.read(() => {
        contentHtml = $generateHtmlFromNodes(this.editor)
      })

      await saveArticle(uuid, slug, { content, content_html: contentHtml })

      if (statusEl) statusEl.textContent = "تم الحفظ"
      this.dirty = false
    } catch (error) {
      console.error("Auto-save failed:", error)
      const statusEl = document.getElementById("save-status")
      if (statusEl) statusEl.textContent = "فشل الحفظ"
      // Keep dirty = true for retry
    } finally {
      this.saving = false
    }
  }

  upsertTitle() {
    if (this.titleDebounceTimer) {
      clearTimeout(this.titleDebounceTimer)
    }

    this.titleDebounceTimer = setTimeout(() => this.saveTitle(), 500)
  }

  async saveTitle() {
    const title = document.getElementById("article-title")?.value
    if (!title) return

    try {
      let uuid, slug

      if (isNewArticle()) {
        const data = await createArticle()
        drawUrl(data)
        this.activatePublishingButton(data.article.uuid, data.user.slug)
        uuid = data.article.uuid
        slug = data.user.slug
      } else {
        uuid = articleUuid()
        slug = userSlug()
        this.activatePublishingButton(uuid, slug)
      }

      await saveArticle(uuid, slug, { title })
    } catch (error) {
      console.error("Title save failed:", error)
    }
  }

  activatePublishingButton(uuid, slug) {
    const btn = document.querySelector(".btn-publish-disabled")
    if (btn) {
      btn.classList.remove("btn-publish-disabled")
    }

    const form = document.getElementById("publish-form-btn")
    if (form) form.action = `/${slug}/publish_modal/${uuid}`
  }

  // === Formatting Actions ===

  toggleBold() {
    this.editor.dispatchCommand(FORMAT_TEXT_COMMAND, "bold")
  }

  toggleItalic() {
    this.editor.dispatchCommand(FORMAT_TEXT_COMMAND, "italic")
  }

  toggleHead1() {
    this.editor.update(() => {
      const selection = $getSelection()
      if (!$isRangeSelection(selection)) return
      const anchorNode = selection.anchor.getNode()
      const element = anchorNode.getTopLevelElementOrThrow()
      if (element.getType() === "heading" && element.getTag() === "h1") {
        $setBlocksType(selection, () => $createParagraphNode())
      } else {
        $setBlocksType(selection, () => $createHeadingNode("h1"))
      }
    })
  }

  toggleHead2() {
    this.editor.update(() => {
      const selection = $getSelection()
      if (!$isRangeSelection(selection)) return
      const anchorNode = selection.anchor.getNode()
      const element = anchorNode.getTopLevelElementOrThrow()
      if (element.getType() === "heading" && element.getTag() === "h2") {
        $setBlocksType(selection, () => $createParagraphNode())
      } else {
        $setBlocksType(selection, () => $createHeadingNode("h2"))
      }
    })
  }

  toggleQuote() {
    this.editor.update(() => {
      const selection = $getSelection()
      if (!$isRangeSelection(selection)) return
      const anchorNode = selection.anchor.getNode()
      const element = anchorNode.getTopLevelElementOrThrow()
      if (element.getType() === "quote") {
        $setBlocksType(selection, () => $createParagraphNode())
      } else {
        $setBlocksType(selection, () => $createQuoteNode())
      }
    })
  }

  // === Link ===

  toggleLink() {
    const toolTip = document.querySelector(".tooltip-controls")
    const linkTip = document.querySelector(".link-tip")

    if (toolTip.style.display === "block") {
      toolTip.style.display = "none"
      linkTip.style.display = "block"

      // Save the Lexical selection anchor/focus before focus moves to the link input
      this.editor.getEditorState().read(() => {
        const selection = $getSelection()
        if ($isRangeSelection(selection)) {
          this._savedSelection = {
            anchorKey:    selection.anchor.key,
            anchorOffset: selection.anchor.offset,
            anchorType:   selection.anchor.type,
            focusKey:     selection.focus.key,
            focusOffset:  selection.focus.offset,
            focusType:    selection.focus.type,
          }
        }
      })

      // Position link input centered above the selection
      const nativeSelection = window.getSelection()
      if (nativeSelection.rangeCount > 0) {
        const range = nativeSelection.getRangeAt(0)
        const rect = range.getBoundingClientRect()
        const editorRect = this.element.getBoundingClientRect()
        const center = rect.left + rect.width / 2
        linkTip.style.top = `${rect.top - editorRect.top - 44}px`
        linkTip.style.left = `${center - editorRect.left}px`
        linkTip.style.width = "280px"
        linkTip.style.marginTop = "0"
        linkTip.style.marginLeft = "0"
      }

      document.getElementById("link").focus()
    } else {
      toolTip.style.display = "block"
      linkTip.style.display = "none"
    }
  }

  enterLinkTip(event) {
    event.preventDefault()
    event.stopPropagation()
    const linkTip = document.querySelector(".link-tip")
    const toolTip = document.querySelector(".tooltip-controls")
    const linkInput = document.getElementById("link")
    const linkValue = linkInput.value.trim()

    if (!linkValue) return

    this._applyLink(linkValue)
    linkInput.value = ""
    linkTip.style.display = "none"
    toolTip.style.display = "none"
  }

  hideLinkTip(event) {
    const linkTip = document.querySelector(".link-tip")
    const linkInput = document.getElementById("link")
    const linkValue = linkInput.value.trim()

    if (this.element === event.target || this.element.contains(event.target)) return
    if (linkValue) {
      this._applyLink(linkValue)
      linkInput.value = ""
    }
    linkTip.style.display = "none"
    this.hideToolTip(event)
  }

  _applyLink(url) {
    const saved = this._savedSelection
    if (!saved) return

    this.editor.update(() => {
      const selection = $createRangeSelection()
      selection.anchor.set(saved.anchorKey, saved.anchorOffset, saved.anchorType)
      selection.focus.set(saved.focusKey, saved.focusOffset, saved.focusType)
      $setSelection(selection)
      $toggleLink(url)
    })
    this._savedSelection = null
  }

  hideToolTip(event) {
    if (this.element === event.target || this.element.contains(event.target)) return
    const toolTip = document.querySelector(".tooltip-controls")
    toolTip.style.display = "none"
  }

  closeTips() {
    const linkTip = document.querySelector(".link-tip")
    const videoTip = document.querySelector(".video-input")
    const toolTip = document.querySelector(".tooltip-controls")
    const tweetTip = document.querySelector(".tweet-input")

    document.getElementById("link").value = ""
    document.getElementById("video").value = ""
    document.getElementById("tweet").value = ""

    linkTip.style.display = "none"
    toolTip.style.display = "none"
    videoTip.style.display = "none"
    tweetTip.style.display = "none"

    this.editor.focus()
  }

  // === Media Insertion ===

  imageUpload() {
    const input = document.createElement("input")
    input.type = "file"
    input.accept = "image/png, image/jpeg"

    input.onchange = () => {
      const file = input.files[0]
      if (!file) return

      const baseURL = window.location.origin
      const url = `${baseURL}/rails/active_storage/direct_uploads`
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) {
          alert("فشل رفع الصورة!")
          return
        }

        const imageUrl = `${baseURL}/rails/active_storage/blobs/proxy/${blob.signed_id}/${blob.filename}`
        this.editor.update(() => {
          const imageNode = $createImageNode({ src: imageUrl, alt: "" })
          const newParagraph = $createParagraphNode()
          $insertNodes([imageNode, newParagraph])
          newParagraph.select()
        })

        // Only hide sidebar bar, let updateToolbar() reposition the + button
        const sidebar = document.querySelector(".sidebar-controls")
        if (sidebar) sidebar.style.display = "none"
      })
    }
    input.click()
  }

  toggleVideoInput() {
    const videoInput = document.querySelector(".video-input")
    const sidebar = document.querySelector(".sidebar-controls")
    const controls = document.querySelector(".show-controls")

    if (videoInput.style.display === "block") {
      videoInput.style.display = "none"
    } else {
      this.positionMediaInput(videoInput)
      sidebar.style.display = "none"
      controls.style.display = "none"
      document.getElementById("video").focus()
    }
  }

  enterVideoTip() {
    const videoTip = document.querySelector(".video-input")
    const videoLink = document.getElementById("video").value
    const validUrl = validateVideoUrl(videoLink)

    if (validUrl) {
      this.editor.update(() => {
        const newParagraph = $createParagraphNode()
        $insertNodes([$createVideoNode(validUrl), newParagraph])
        newParagraph.select()
      })
      document.getElementById("video").value = ""
      videoTip.style.display = "none"
    } else {
      alert("رابط فيديو غير صالح! استخدم رابط يوتيوب أو فيميو كامل")
    }
  }

  hideVideoTip(event) {
    const videoTip = document.querySelector(".video-input")
    const videoLink = document.getElementById("video").value
    const validUrl = validateVideoUrl(videoLink)

    if (this.element === event.target || this.element.contains(event.target)) return
    if (validUrl) {
      this.editor.update(() => {
        const newParagraph = $createParagraphNode()
        $insertNodes([$createVideoNode(validUrl), newParagraph])
        newParagraph.select()
      })
      document.getElementById("video").value = ""
    }
    videoTip.style.display = "none"
  }

  toggleTweetInput() {
    const tweetInput = document.querySelector(".tweet-input")
    const sidebar = document.querySelector(".sidebar-controls")
    const controls = document.querySelector(".show-controls")

    if (tweetInput.style.display === "block") {
      tweetInput.style.display = "none"
    } else {
      this.positionMediaInput(tweetInput)
      sidebar.style.display = "none"
      controls.style.display = "none"
      document.getElementById("tweet").focus()
    }
  }

  enterTweetTip(event) {
    event.preventDefault()
    const tweetTip = document.querySelector(".tweet-input")
    const tweetLink = document.getElementById("tweet").value
    const tweetId = validateTweetUrl(tweetLink)

    if (tweetId) {
      this.editor.update(() => {
        const newParagraph = $createParagraphNode()
        $insertNodes([$createTweetNode(tweetId), newParagraph])
        newParagraph.select()
      })
      document.getElementById("tweet").value = ""
      tweetTip.style.display = "none"
      this.hideSidebar()
    } else {
      alert("رابط تغريدة غير صالح! استخدم رابط التغريدة الكامل")
    }
  }

  hideTweetTip(event) {
    const tweetTip = document.querySelector(".tweet-input")
    const tweetLink = document.getElementById("tweet").value
    const tweetId = validateTweetUrl(tweetLink)

    if (this.element === event.target || this.element.contains(event.target)) return
    if (tweetId) {
      this.editor.update(() => {
        const newParagraph = $createParagraphNode()
        $insertNodes([$createTweetNode(tweetId), newParagraph])
        newParagraph.select()
      })
      document.getElementById("tweet").value = ""
    }
    tweetTip.style.display = "none"
    this.hideSidebar()
  }

  toggleDivder() {
    this.editor.update(() => {
      const newParagraph = $createParagraphNode()
      $insertNodes([$createDividerNode(), newParagraph])
      newParagraph.select()
    })
  }

  // === Controls & Toolbar ===

  toggleControls() {
    const controls = document.querySelector(".show-controls")
    const sidebar = document.querySelector(".sidebar-controls")

    if (controls.style.display === "block") {
      controls.style.display = "none"
      sidebar.style.display = "block"
    } else {
      controls.style.display = "block"
      sidebar.style.display = "none"
    }
  }

  updateToolbar() {
    const toolTip = document.querySelector(".tooltip-controls")
    const controls = document.querySelector(".show-controls")
    const sidebar = document.querySelector(".sidebar-controls")

    const nativeSelection = window.getSelection()
    if (!nativeSelection || nativeSelection.rangeCount === 0) return

    const range = nativeSelection.getRangeAt(0)
    const editorRect = this.element.getBoundingClientRect()

    if (nativeSelection.isCollapsed) {
      toolTip.style.display = "none"

      // Walk up from anchor to find the top-level block (direct child of editor root)
      const rootElement = this.editor.getRootElement()
      let node = nativeSelection.anchorNode
      if (node?.nodeType === Node.TEXT_NODE) node = node.parentElement

      let block = node
      while (block && block.parentElement !== rootElement) {
        block = block.parentElement
      }

      if (block && block.parentElement === rootElement) {
        // Only show + button on empty <p> elements
        const isEmptyParagraph =
          block.tagName === "P" &&
          block.textContent.trim() === "" &&
          block.querySelectorAll("img, iframe, div, figure").length === 0

        if (isEmptyParagraph) {
          const rect = block.getBoundingClientRect()
          const top = rect.top - editorRect.top + (rect.height / 2) - 16

          controls.style.display = "block"
          controls.style.top = `${top}px`
          controls.style.left = "auto"
          controls.style.right = "-48px"

          sidebar.style.top = `${top}px`
          sidebar.style.left = "auto"
          sidebar.style.right = "-48px"
        } else {
          controls.style.display = "none"
          sidebar.style.display = "none"
        }
      } else {
        controls.style.display = "none"
        sidebar.style.display = "none"
      }
    } else {
      // Range selection — center toolbar above selected text
      const rect = range.getBoundingClientRect()
      const selectionCenter = rect.left + rect.width / 2
      const top = rect.top - editorRect.top - 44

      toolTip.style.display = "block"
      toolTip.style.top = `${top}px`
      toolTip.style.left = `${selectionCenter - editorRect.left}px`
      // Reset any stale margin values
      toolTip.style.marginTop = "0"
      toolTip.style.marginLeft = "0"
      toolTip.style.marginRight = "0"
    }
  }

  // === Helpers ===

  showControlsAtCaret() {
    const controls = document.querySelector(".show-controls")
    const sidebar = document.querySelector(".sidebar-controls")
    if (!controls) return

    const rootElement = this.editor.getRootElement()
    if (rootElement) {
      const firstChild = rootElement.firstElementChild
      if (firstChild) {
        const rect = firstChild.getBoundingClientRect()
        const editorRect = this.element.getBoundingClientRect()
        const top = rect.top - editorRect.top + (rect.height / 2) - 16
        controls.style.display = "block"
        controls.style.top = `${top}px`
        controls.style.left = "auto"
        controls.style.right = "-48px"

        if (sidebar) {
          sidebar.style.display = "none"
          sidebar.style.top = `${top}px`
          sidebar.style.left = "auto"
          sidebar.style.right = "-48px"
        }
      }
    }
  }

  hideSidebar() {
    const sidebar = document.querySelector(".sidebar-controls")
    const controls = document.querySelector(".show-controls")
    if (sidebar) sidebar.style.display = "none"
    if (controls) controls.style.display = "none"
  }

  getCaretRect() {
    const nativeSelection = window.getSelection()
    if (!nativeSelection || nativeSelection.rangeCount === 0) return null
    const range = nativeSelection.getRangeAt(0)
    return range.getBoundingClientRect()
  }

  positionMediaInput(inputEl) {
    const rect = this.getCaretRect()
    const editorRect = this.element.getBoundingClientRect()

    inputEl.style.display = "block"
    inputEl.style.position = "absolute"
    inputEl.style.width = "280px"
    inputEl.style.left = "auto"

    if (rect && rect.height > 0) {
      inputEl.style.top = `${rect.top - editorRect.top + rect.height + 8}px`
      inputEl.style.right = "0px"
    } else {
      // Fallback: position at the + button location
      const controls = document.querySelector(".show-controls")
      if (controls) {
        inputEl.style.top = controls.style.top
        inputEl.style.right = "0px"
      }
    }
  }
}
