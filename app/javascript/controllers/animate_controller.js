import { Controller } from "@hotwired/stimulus"

var app = {

  chars: ['ن','م','ي','م'],

  init: function () {
    app.container = document.getElementById('animation-container');
    window.setInterval(app.add, 100);
  },

  add: function () {
    var element = document.createElement('span');
    app.container.appendChild(element);
    app.animate(element);
  },

  animate: function (element) {
    var character = app.chars[Math.floor(Math.random() * app.chars.length)];
    var duration = Math.floor(Math.random() * 15) + 1;
    var offset = Math.floor(Math.random() * (50 - duration * 2)) + 3;
    var size = 10 + (15 - duration);
    element.style.cssText = 'left:'+offset+'vw; font-size:'+size+'px;animation-duration:'+duration+'s';
    element.innerHTML = character;
    setTimeout(app.remove, 3000, element);
  },

  remove: function (element) {
    element.parentNode.removeChild(element);
  },

};
export default class extends Controller {
  initialize() {
     app.init();
  }
}
