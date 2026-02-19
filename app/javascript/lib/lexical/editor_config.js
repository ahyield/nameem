import { createEditor } from "lexical"
import { HeadingNode, QuoteNode, registerRichText } from "@lexical/rich-text"
import { LinkNode } from "@lexical/link"
import { createEmptyHistoryState, registerHistory } from "@lexical/history"
import { ImageNode } from "lib/lexical/nodes/image_node"
import { VideoNode } from "lib/lexical/nodes/video_node"
import { TweetNode } from "lib/lexical/nodes/tweet_node"
import { DividerNode } from "lib/lexical/nodes/divider_node"

export function createNamoemEditor(container) {
  const editor = createEditor({
    namespace: "nameem",
    nodes: [HeadingNode, QuoteNode, LinkNode, ImageNode, VideoNode, TweetNode, DividerNode],
    theme: {
      paragraph: "editor-paragraph",
      heading: { h1: "text-3xl font-bold", h2: "text-2xl font-bold" },
      quote: "editor-blockquote",
      link: "text-blue-500 font-semibold no-underline hover:underline",
      text: { bold: "font-bold", italic: "italic", underline: "underline" },
    },
    onError: (error) => console.error(error),
  })

  editor.setRootElement(container)
  registerRichText(editor)
  registerHistory(editor, createEmptyHistoryState(), 300)

  return editor
}
