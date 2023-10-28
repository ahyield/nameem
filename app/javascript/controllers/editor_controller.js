// I am ashamed of it.
// needs hygine, but works for now.

import { Controller } from "@hotwired/stimulus"
import Quill from "quill";

let Block = Quill.import('blots/block');
let BlockEmbed = Quill.import('blots/block/embed');

function outerWidth(el) {
  const style = getComputedStyle(el);

  return (
    el.getBoundingClientRect().width +
    parseFloat(style.marginLeft) +
    parseFloat(style.marginRight)
  );
}

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
const editor = new Quill(".editor-container");

export default class extends Controller {
  initalize() {
    this.boldToggle = false;
    this.italicToggle = false;
    this.quoteToggle = false;
    this.head1Toggle = false;
    this.head2Toggle = false;
  }

  connect() {
    const toolTip = document.querySelector(".tooltip-controls");
    const sidebar = document.querySelector(".sidebar-controls");
    const editorContainer = document.getElementById("editor");
    editor.format('direction', 'rtl');
    editor.format('align', 'right');


    editor.on(Quill.events.EDITOR_CHANGE, function(event, range) {
      if (event !== Quill.events.SELECTION_CHANGE) return;
      if (range === null) return;

     let rangeBounds = editor.getBounds(range.index, range.length);
     if (range.length === 0) {
       toolTip.style.display = 'none';
       let [block, offset] = editor.scroll.descendant(Block, range.index);

       if (block != null && block.domNode.firstChild instanceof HTMLBRElement) {
         sidebar.style.display = "block";
         sidebar.style.marginTop = `${rangeBounds.top - 8}px`;
         sidebar.style.left = `${ 8 + rangeBounds.left}px`;
         // position the sidebar

       } else {
         sidebar.style.display = "none";
       }
     } else if (range.length > 0 ) {
       toolTip.style.display = 'block';
       // position the tooltip
       toolTip.style.left = "0px";
       toolTip.style.marginRight = "-180px"; // Hack to enable proper styling.
       toolTip.style.marginLeft = `${rangeBounds.left - 100}px`;
       toolTip.style.marginTop = `${rangeBounds.top - 40}px`;
     }
    });
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
      linkTip.style.width = "14.6%";
      linkTip.style.marginLeft = `${rangeBounds.left - 100}px`;
      linkTip.style.marginTop = `${rangeBounds.top - 40}px`;
      document.getElementById("link").focus();
    } else {
      toolTip.style.display = 'block';
      linkTip.style.display = 'none';
    }
  }

  toggleBold() {
    if(this.boldToggle === true) {
      editor.format('bold', false);
      this.boldToggle = false;
    } else {
      editor.format('bold', true);
      this.boldToggle = true;
    }
  }

  toggleItalic() {
    if(this.italicToggle === true) {
      editor.format('italic', false);
      this.italicToggle = false;
    } else {
      editor.format('italic', true);
      this.italicToggle = true;
    }
  }

  toggleQuote() {
    if(this.quoteToggle === true) {
      editor.format('blockquote', false);
      this.quoteToggle = false;
    } else {
      editor.format('blockquote', true);
      this.quoteToggle = true;
    }
  }

  toggleHead1() {
    if(this.head1Toggle === true) {
      editor.format('header', false);
      this.head1Toggle = false;
    } else {
      editor.format('header', 1);
      this.head1Toggle = true;
    }
  }

  toggleHead2() {
    if(this.head2Toggle === true) {
      editor.format('header', false);
      this.head2Toggle = false;
    } else {
      editor.format('header', 2);
      this.head2Toggle = true;
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
      let files =   Array.from(input.files);
      console.log(files);
      editor.insertEmbed(range.index, 'image', {
        url: "https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png",
      }, Quill.sources.USER);
      editor.setSelection(range.index + 1, Quill.sources.SILENT);
    };
    input.click();
  }
}
