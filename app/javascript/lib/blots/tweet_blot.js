import { BaseBlot } from "lib/blots/base_blot"

export class TweetBlot extends BaseBlot {
  static create(id) {
    const node = super.create()
    node.dataset.id = id
    twttr.widgets.createTweet(id, node) // eslint-disable-line
    return node
  }

  static value(domNode) {
    return domNode.dataset.id
  }
}

TweetBlot.blotName = "tweet"
TweetBlot.tagName = "div"
TweetBlot.className = "tweet"

export default TweetBlot
