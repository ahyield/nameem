import { DecoratorNode } from "lexical"

export class DividerNode extends DecoratorNode {
  static getType() {
    return "divider"
  }

  static clone(node) {
    return new DividerNode(node.__key)
  }

  constructor(key) {
    super(key)
  }

  static importJSON() {
    return $createDividerNode()
  }

  exportJSON() {
    return {
      type: "divider",
      version: 1,
    }
  }

  createDOM() {
    const hr = document.createElement("hr")
    hr.className = "editor-hr"
    return hr
  }

  // A block of its own: inline, it would sit inside an empty paragraph that adds space around it
  isInline() {
    return false
  }

  updateDOM() {
    return false
  }

  exportDOM() {
    const hr = document.createElement("hr")
    hr.className = "editor-hr"
    return { element: hr }
  }

  static importDOM() {
    return {
      hr: () => ({
        conversion: convertHrElement,
        priority: 0,
      }),
    }
  }

  decorate() {
    return null
  }
}

function convertHrElement() {
  return { node: $createDividerNode() }
}

export function $createDividerNode() {
  return new DividerNode()
}

export function $isDividerNode(node) {
  return node instanceof DividerNode
}
