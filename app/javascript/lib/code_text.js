// The text of a code block as it should be copied: line breaks from <br>, and without the copy button
export function codeText(pre) {
  const copy = pre.cloneNode(true)
  copy.querySelectorAll("[data-code-copy-ignore]").forEach((element) => element.remove())
  copy.querySelectorAll("br").forEach((br) => br.replaceWith("\n"))
  return copy.textContent.replace(/\n$/, "")
}
