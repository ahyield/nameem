import { createEditor } from "lexical"
import { HeadingNode, QuoteNode, registerRichText } from "@lexical/rich-text"
import { LinkNode } from "@lexical/link"
import { createEmptyHistoryState, registerHistory } from "@lexical/history"
import { CodeHighlightNode, CodeNode, PrismTokenizer, registerCodeHighlighting } from "@lexical/code"
import "prismjs/components/prism-ruby"
import "prismjs/components/prism-bash"
import "prismjs/components/prism-json"
import "prismjs/components/prism-yaml"
import "prismjs/components/prism-go"
import { CODE, INLINE_CODE, registerMarkdownShortcuts } from "@lexical/markdown"
import { ImageNode } from "lib/lexical/nodes/image_node"
import { VideoNode } from "lib/lexical/nodes/video_node"
import { TweetNode } from "lib/lexical/nodes/tweet_node"
import { DividerNode } from "lib/lexical/nodes/divider_node"

// Prism token types → a handful of colour classes (styled in application.css for light and dark)
const CODE_TOKEN_CLASSES = {
  comment: "tok-comment", prolog: "tok-comment", doctype: "tok-comment", cdata: "tok-comment",
  keyword: "tok-keyword", atrule: "tok-keyword", important: "tok-keyword", selector: "tok-keyword",
  string: "tok-string", char: "tok-string", "attr-value": "tok-string", regex: "tok-string", url: "tok-string",
  inserted: "tok-string",
  number: "tok-number", boolean: "tok-number", constant: "tok-number", symbol: "tok-number",
  function: "tok-function", "class-name": "tok-function", class: "tok-function", builtin: "tok-function",
  namespace: "tok-function",
  tag: "tok-tag", property: "tok-tag", "attr-name": "tok-tag", deleted: "tok-tag", key: "tok-tag",
  variable: "tok-variable", parameter: "tok-variable",
  operator: "tok-punctuation", punctuation: "tok-punctuation", entity: "tok-punctuation",
}

// Offered in the language menu on a code block, in this order
export const CODE_LANGUAGES = [
  ["plain", "نص عادي"], ["javascript", "JavaScript"], ["typescript", "TypeScript"], ["python", "Python"],
  ["ruby", "Ruby"], ["go", "Go"], ["java", "Java"], ["c", "C"], ["cpp", "C++"], ["rust", "Rust"], ["swift", "Swift"],
  ["sql", "SQL"], ["bash", "Bash"], ["powershell", "PowerShell"], ["html", "HTML"], ["css", "CSS"], ["json", "JSON"],
  ["yaml", "YAML"], ["markdown", "Markdown"],
]

export function createNamoemEditor(container) {
  const editor = createEditor({
    namespace: "nameem",
    nodes: [HeadingNode, QuoteNode, LinkNode, CodeNode, CodeHighlightNode, ImageNode, VideoNode, TweetNode, DividerNode],
    theme: {
      paragraph: "editor-paragraph",
      heading: { h1: "text-3xl font-bold", h2: "text-2xl font-bold" },
      quote: "editor-blockquote",
      code: "editor-code",
      codeHighlight: CODE_TOKEN_CLASSES,
      link: "text-blue-500 font-semibold no-underline hover:underline",
      text: { bold: "font-bold", italic: "italic", underline: "underline", code: "editor-inline-code" },
    },
    onError: (error) => console.error(error),
  })

  editor.setRootElement(container)
  registerRichText(editor)
  registerHistory(editor, createEmptyHistoryState(), 300)
  // Only the code shortcuts: ``` (or ```python) at the start of a line makes a code block, `word` makes inline code
  registerMarkdownShortcuts(editor, [CODE, INLINE_CODE])
  // Colours come from Prism as you type and are saved with the article; a block stays plain until its language is chosen
  registerCodeHighlighting(editor, { ...PrismTokenizer, defaultLanguage: "plain" })

  return editor
}
