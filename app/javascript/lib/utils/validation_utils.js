// Parse a user-entered URL; only http(s) URLs are accepted
const parseUrl = (input) => {
  try {
    const url = new URL(input.trim())
    return ["http:", "https:"].includes(url.protocol) ? url : null
  } catch {
    return null
  }
}

const hostOf = (url) => url.hostname.toLowerCase().replace(/^(www\.|m\.)/, "")

// Returns a canonical embed URL for YouTube or Vimeo links, or null.
// Hosts are compared exactly and the embed URL is rebuilt from the video ID,
// so nothing else from the input ends up in the iframe src.
export const validateVideoUrl = (input) => {
  const url = parseUrl(input)
  if (!url) return null

  const host = hostOf(url)
  const youtubeId = /^[\w-]{11}$/

  if (host === "youtube.com" || host === "youtube-nocookie.com") {
    const id = url.searchParams.get("v") || url.pathname.match(/^\/(?:embed|v|shorts|live)\/([\w-]{11})/)?.[1]
    return youtubeId.test(id || "") ? `https://www.youtube.com/embed/${id}` : null
  }

  if (host === "youtu.be") {
    const id = url.pathname.slice(1).split("/")[0]
    return youtubeId.test(id) ? `https://www.youtube.com/embed/${id}` : null
  }

  if (host === "vimeo.com" || host === "player.vimeo.com") {
    const match = url.pathname.match(/^\/(?:video\/)?(\d+)(?:\/([\w]+))?/)
    if (!match) return null

    // Unlisted videos carry a privacy hash, either as /ID/HASH or ?h=HASH
    const hash = match[2] || url.searchParams.get("h")
    const query = hash && /^\w+$/.test(hash) ? `?h=${hash}` : ""
    return `https://player.vimeo.com/video/${match[1]}${query}`
  }

  return null
}

// Returns the tweet ID for a twitter.com or x.com status link, or null
export const validateTweetUrl = (input) => {
  const url = parseUrl(input)
  if (!url) return null

  const host = hostOf(url)
  if (!["twitter.com", "x.com", "mobile.twitter.com"].includes(host)) return null

  return url.pathname.match(/^\/[^/]+\/status(?:es)?\/(\d+)/)?.[1] || null
}
