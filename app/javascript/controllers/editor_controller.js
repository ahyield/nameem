import { Controller } from "@hotwired/stimulus"
import Quill from "quill";

export default class extends Controller {

  initalize() {
    this.boldToggle = false;
    this.italicToggle = false;
    this.quoteToggle = false;
    this.head1Toggle = false;
    this.head2Toggle = false;
  }

  connect() {
    this.editor = new Quill(".editor-container");
    const toolTip = document.querySelector(".tooltip-controls");

    this.editor.on(Quill.events.EDITOR_CHANGE, function(event, range) {
      if (event !== Quill.events.SELECTION_CHANGE) return;
      if (range == null) return;

     if (range.length === 0) {
       toolTip.style.display = 'none';
     } else if (range.length > 0 ) {
       toolTip.style.display = 'block';
     }
    });
  }

  toggleBold() {
    if(this.boldToggle === true) {
      this.editor.format('bold', false);
      this.boldToggle = false;
    } else {
      this.editor.format('bold', true);
      this.boldToggle = true;
    }
  }

  toggleItalic() {
    if(this.italicToggle === true) {
      this.editor.format('italic', false);
      this.italicToggle = false;
    } else {
      this.editor.format('italic', true);
      this.italicToggle = true;
    }
  }

  toggleQuote() {
    if(this.quoteToggle === true) {
      this.editor.format('blockquote', false);
      this.quoteToggle = false;
    } else {
      this.editor.format('blockquote', true);
      this.quoteToggle = true;
    }
  }

  toggleHead1() {
    if(this.head1Toggle === true) {
      this.editor.format('header', false);
      this.head1Toggle = false;
    } else {
      this.editor.format('header', 1);
      this.head1Toggle = true;
    }
  }

  toggleHead2() {
    if(this.head2Toggle === true) {
      this.editor.format('header', false);
      this.head2Toggle = false;
    } else {
      this.editor.format('header', 2);
      this.head2Toggle = true;
    }
  }
}
