import { Controller } from "@hotwired/stimulus"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"

export default class extends Controller {
  async connect() {
    const uuid = this.articleUuid()
    const article =  await this.fetchArticle(uuid)
    const deltaOps = article.content.ops

    var converter = new QuillDeltaToHtmlConverter(deltaOps)

    converter.renderCustomWith(function(customOp, contextOp){
      if (customOp.insert.type === "customImage") {
        const url = customOp.insert.value.url
        return `<img src="${url}">`
      } else {
        return "Unmanaged custom blot!"
      }
    })

    var html = converter.convert()

    const div = document.getElementById("quill-renderer")
    div.innerHTML = html
  }


  articleUuid() {
    const uuid = window.location.pathname.split("/")[2]
    return uuid
  }

  async fetchArticle(uuid) {
    const response = await fetch(`/api/articles/${uuid}`, { method: "GET" })

    const data = await response.json()
    return data
  }
}
