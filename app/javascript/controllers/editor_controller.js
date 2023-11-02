// I am ashamed of it.
// needs hygine, but works for now.

import { DirectUpload } from "@rails/activestorage"
import { Controller } from "@hotwired/stimulus"
import Quill from "quill";

let Block = Quill.import('blots/block');
let BlockEmbed = Quill.import('blots/block/embed');
let Delta = Quill.import('delta');

class ImageBlot extends BlockEmbed {
  static create(value) {
    let node = super.create();
    node.setAttribute('src', value.url);
    return node;
  }

  static value(node) {
    return {
      url: node.getAttribute('src')
    };
  }
}

ImageBlot.blotName = 'image';
ImageBlot.tagName = 'img';

Quill.register(ImageBlot);

let editor = null;
let change = new Delta();

//helper shit
function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export default class extends Controller {
  async connect() {
    var editorOptions = {
      debug: 'error',
      placeholder: "إبدأ بالكتابة...",
      scrollingContainer: 'html',
    };

    editor = new Quill(".editor-container", editorOptions);

    const toolTip = document.querySelector(".tooltip-controls");
    const sidebar = document.querySelector(".sidebar-controls");
    const editorContainer = document.getElementById("editor");
    editor.format('direction', 'rtl');
    editor.format('align', 'right');

    let range = editor.getSelection();
    let rangeBounds = editor.getBounds(range);

    sidebar.style.display = "block";
    sidebar.style.marginTop = `${rangeBounds.top + 135}px`;
    sidebar.style.left = `${ 8 + rangeBounds.left}px`;

    editor.on(Quill.events.EDITOR_CHANGE, function(event, range) {
      if (event !== Quill.events.SELECTION_CHANGE) return;
      if (range === null) return;

     let rangeBounds = editor.getBounds(range.index, range.length);
     if (range.length === 0) {
       toolTip.style.display = 'none';
       let [block, offset] = editor.scroll.descendant(Block, range.index);

       if (block != null && block.domNode.firstChild instanceof HTMLBRElement) {
         sidebar.style.display = "block";
         sidebar.style.marginTop = `${rangeBounds.top + 135}px`;
         sidebar.style.left = `${ 8 + rangeBounds.left}px`;
       } else {
         sidebar.style.display = "none";
       }
     } else if (range.length > 0 ) {
       toolTip.style.display = 'block';
       // position the tooltip
       toolTip.style.left = "0px";
       toolTip.style.marginRight = "-180px"; // Hack to enable proper styling.
       toolTip.style.marginLeft = `${rangeBounds.left - 100}px`;
       toolTip.style.marginTop = `${rangeBounds.top + 90}px`;
     }
    });

    if (!this.isNewArticle()) {
      let articleTitle = document.getElementById("article-title");
      let publishButton = document.querySelector(".btn-publish-disabled");
      let publichText = document.querySelector(".btn-publish-text");

      publichText.innerHTML = "حفظ ونشر";
      publishButton.classList.remove("btn-publish-disabled");

      const uuid = this.articleUuid();
      const article = await this.fetchArticle(uuid);
      sidebar.style.display = "none";
      articleTitle.value = article.title;
      editor.setContents(article.content);
    }

    editor.on("text-change", (delta, oldContents, source) => {
      if (source !== 'user') return;

      const inserted = this.getImgUrls(delta);
      const deleted = this.getImgUrls(editor.getContents().diff(oldContents));

      change = change.compose(delta);
      if(deleted.length >= 1) {
        fetch(`/api/attachments/delete?image_url=${deleted[0].url}`, { method: 'DELETE' })
      }
    });

    // wow
    setInterval(async () => {
      if (change.length() > 0) {
        if (this.isNewArticle()) {
          const data = await this.newArticle();
          this.drawUrl(data);
          this.activatePublishingButton();
          const article = await this.updateArticleContent(data.uuid);
        } else {
          var uuid = this.articleUuid();
          this.activatePublishingButton();
          const article = await this.updateArticleContent(uuid);
        }
        change = new Delta();
      }
    }, 2 * 1000);
  }

  async fetchArticle(uuid) {
    const response = await fetch(`/api/articles/${uuid}/edit`, { method: 'GET' })

    const data = await response.json();
    return data;
  }

  async newArticle() {
    const response = await fetch("/api/articles/new", { method: 'GET' })

    const data = await response.json();
    return data;
  }

  isNewArticle() {
    let path = window.location.pathname
    if (path === '/new-story') {
      return true;
    } else {
      return false;
    }
  }

  async upsertTitle(event) {
    await timeout("2000");

    if (this.isNewArticle()) {
      let data = await this.newArticle();
      this.drawUrl(data);
      this.activatePublishingButton();
      const article = await this.updateArticleTitle(data.uuid);
      } else {
        var uuid = this.articleUuid();
        this.activatePublishingButton();
        const article = await this.updateArticleTitle(uuid);
      }
  }

  async updateArticleTitle(uuid) {
    const articleTitle = document.getElementById("article-title").value;

    const response = await fetch(`/api/articles/${uuid}/edit`, {
      method: 'PUT',
      body: JSON.stringify({ article: { title: articleTitle, content: editor.getContents(), }}),
      headers: {
        "CONTENT-TYPE": "application/json",
      }
    });
    const article = await response.json();
    return article;
  }

  async updateArticleContent(uuid) {
    const response = await fetch(`/api/articles/${uuid}/edit`, {
      method: 'PUT',
      body: JSON.stringify({ article: { content: editor.getContents(), }}),
      headers: {
        "CONTENT-TYPE": "application/json",
      }
    });
    const article = await response.json();
    return article;
  }

  articleUuid() {
    const uuid = window.location.pathname.split("/")[2];
    return uuid;
  }

  drawUrl(data) {
    let url = window.location.origin + `/articles/${data.uuid}/edit`
    window.history.pushState(null, null, url);
  }

  isUuid(uuid) {
    let s = `${uuid}`;

    s = s.match(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    );
    if (s === null) {
      return false;
    }
    return true;
  }

  activatePublishingButton() {
    const btn = document.querySelector(".btn-publish-disabled");
    if(btn) {
      btn.classList.remove("btn-publish-disabled");
    }
  }

  getImgUrls(delta) {
    return delta.ops.filter(i => i.insert && i.insert.image).map(i => i.insert.image);
  }

  toggleLink() {
    const toolTip = document.querySelector(".tooltip-controls");
    const linkTip = document.querySelector(".link-tip");

    let range = editor.getSelection();
    let rangeBounds = editor.getBounds(range.index, range.length);

    if(toolTip.style.display === 'block') {
      toolTip.style.display = 'none';
      linkTip.style.display = 'block';
      linkTip.style.left = "0px";
      linkTip.style.width = "22%";
      linkTip.style.marginLeft = `${rangeBounds.left - 100}px`;
      linkTip.style.marginTop = `${rangeBounds.top + 90}px`;
      document.getElementById("link").focus();
    } else {
      toolTip.style.display = 'block';
      linkTip.style.display = 'none';
    }
  }

  toggleBold() {
    let range = editor.getSelection();
    let format = editor.getFormat(range);
    if (format.bold === undefined) {
      editor.format("bold", true);
    } else {
      editor.format("bold", false);
    }
  }

  toggleItalic() {
    let range = editor.getSelection();
    let format = editor.getFormat(range);
    if (format.italic === undefined) {
      editor.format("italic", true);
    } else {
      editor.format("italic", false);
    }
  }

  toggleQuote() {
    let range = editor.getSelection();
    let format = editor.getFormat(range);
    if (format.blockquote === undefined) {
      editor.format("blockquote", true);
    } else {
      editor.format("blockquote", false);
    }
  }

  toggleHead1() {
    let range = editor.getSelection();
    let format = editor.getFormat(range);
    if (format.header === undefined) {
      editor.format("header", 1);
    } else {
      editor.format("header", false);
    }
  }

  toggleHead2() {
    let range = editor.getSelection();
    let format = editor.getFormat(range);
    if (format.header === undefined) {
      editor.format("header", 2);
    } else {
      editor.format("header", false);
    }
  }

  closeTips(event) {
    const linkTip = document.querySelector(".link-tip");
    const toolTip = document.querySelector(".tooltip-controls");
    document.getElementById("link").value = "";

    linkTip.style.display = 'none';
    toolTip.style.display = 'none';
  }

  enterLinkTip(event) {
    const linkTip = document.querySelector(".link-tip");
    const toolTip = document.querySelector(".tooltip-controls");
    var linkValue = document.getElementById("link").value;

    document.getElementById('link').addEventListener('keypress', function (e) {
      if (e.key === 'Enter') {
        editor.format('link', linkValue);
        document.getElementById("link").value = "";

        linkTip.style.display = 'none';
        toolTip.style.display = 'none';
      }
    });
  }

  hideLinkTip(event) {
    const linkTip = document.querySelector(".link-tip");
    var linkValue = document.getElementById("link").value;

    let range = editor.getSelection();

    if (range && range.length === 0) {
      linkTip.style.display = 'none';
    }

    // no clue how this works
    if(this.element === event.target || this.element.contains(event.target)) return;
    if(linkValue) {
      editor.format('link', linkValue);
      document.getElementById("link").value = "";
    }
    linkTip.style.display = 'none';
    this.hideToolTip(event);
  }

  hideToolTip(event) {
    if(this.element === event.target || this.element.contains(event.target)) return;

    const toolTip = document.querySelector(".tooltip-controls");
    toolTip.style.display = 'none';
  }

  imageUpload(event) {
    let input = document.createElement('input');
    input.type = 'file';
    input.accept = "image/png, image/jpeg";

    input.onchange = _ => {
      let range = editor.getSelection(true);
      let file =   input.files[0];

      const url = "/rails/active_storage/direct_uploads"
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) {
          alert("Uploading failed!");
        } else {
          editor.insertEmbed(range.index, 'image', {
            url: `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`,
          }, Quill.sources.USER);
          editor.setSelection(range.index + 1, Quill.sources.SILENT);
          const sidebar = document.querySelector(".sidebar-controls");
          sidebar.style.display = "none";
        }
      });
    };
    input.click();
  }
}
