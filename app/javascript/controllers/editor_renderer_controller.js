import { Controller } from "@hotwired/stimulus"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"

export default class extends Controller {
  async connect() {
    const uuid = this.articleUuid()
    const slug = this.userSlug()
    const article =  await this.fetchArticle(uuid, slug)
    const deltaOps = article.content.ops

    const cfg = {
      customCssClasses: (op) => {
      if (op.attributes.link){
        return ["text-blue-500 font-semibold no-underline hover:underline"]
      }

      if (op.attributes.blockquote){
        return ["text-xl italic font-semibold text-gray-900 pr-3"]
      }}
    }

    var converter = new QuillDeltaToHtmlConverter(deltaOps, cfg)

    converter.renderCustomWith(function(customOp, contextOp){
      if (customOp.insert.type === "customImage") {
        const url = customOp.insert.value.url
        return `<img src="${url}", class="py-4">`
      } else if (customOp.insert.type === "tweet") {
        return `<div id="${customOp.insert.value}" class="tweet-block"></div>`
      } else if (customOp.insert.type === "divider") {
        return "<hr class=\"my-1\" />"
      }
    })

    var html = converter.convert()

    const div = document.getElementById("quill-renderer")
    div.innerHTML = html

    const tweet = document.querySelector(".tweet-block")
    if (tweet) {
      twttr.widgets.createTweet(tweet.id, tweet) // eslint-disable-line no-undef
    }
  }


  articleUuid() {
    const uuid = window.location.pathname.split("/")[2]
    return uuid
  }

  userSlug() {
    const slug = window.location.pathname.split("/")[1]
    return slug
  }

  async fetchArticle(uuid, slug) {
    const response = await fetch(`/api/articles/${slug}/${uuid}`, { method: "GET" })

    const data = await response.json()
    return data
  }
}
