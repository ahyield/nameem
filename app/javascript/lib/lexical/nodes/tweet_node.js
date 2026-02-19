import { DecoratorNode } from "lexical"

export class TweetNode extends DecoratorNode {
  __tweetId

  static getType() {
    return "tweet"
  }

  static clone(node) {
    return new TweetNode(node.__tweetId, node.__key)
  }

  constructor(tweetId, key) {
    super(key)
    this.__tweetId = tweetId
  }

  static importJSON(serializedNode) {
    return $createTweetNode(serializedNode.tweetId)
  }

  exportJSON() {
    return {
      type: "tweet",
      version: 1,
      tweetId: this.__tweetId,
    }
  }

  createDOM() {
    const div = document.createElement("div")
    div.className = "tweet-embed"
    div.dataset.tweetId = this.__tweetId
    return div
  }

  updateDOM() {
    return false
  }

  exportDOM() {
    const div = document.createElement("div")
    div.className = "tweet-embed"
    div.dataset.tweetId = this.__tweetId
    return { element: div }
  }

  static importDOM() {
    return {
      div: (domNode) => {
        if (!domNode.hasAttribute("data-tweet-id")) return null
        return {
          conversion: convertTweetElement,
          priority: 1,
        }
      },
    }
  }

  decorate() {
    return null
  }
}

function convertTweetElement(domNode) {
  const tweetId = domNode.getAttribute("data-tweet-id")
  if (!tweetId) return null
  return { node: $createTweetNode(tweetId) }
}

export function $createTweetNode(tweetId) {
  return new TweetNode(tweetId)
}

export function $isTweetNode(node) {
  return node instanceof TweetNode
}
