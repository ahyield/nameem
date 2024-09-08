export const validateVideoUrl = (url) => {
  const youtubePattern = /^(https?:\/\/)(www\.)?(youtube\.com\/(.*\/)?(v\/|e\/|u\/\w+\/|embed\/|v=|vi=|t=|\?v=|\?vi=|\?u=|\?e=|\?t=)?([^#]*))(#[\w]*)?$/
  const youtubeShortPattern = /^(https?:\/\/)(www\.)?(youtu\.be\/)([^#]*)?(#[\w]*)?$/
  const vimeoPattern = /^(https?:\/\/)(www\.)?(vimeo\.com\/|player\.vimeo\.com\/video\/)?([0-9]+)(\?h=[\w]+)?(\/)?([^#]*)(#[\w]*)?$/

  if (youtubePattern.test(url)) {
    return url.replace("watch?v=", "embed/")
  } else if (youtubeShortPattern.test(url)) {
    return url.replace("youtu.be/", "www.youtube.com/embed/")
  } else if (vimeoPattern.test(url)) {
    if (url.includes("player.vimeo.com/video")) {
      return url
    } else if (url.includes("vimeo.com")) {
      return url.replace("vimeo.com", "player.vimeo.com/video")
    }
  }
  return null
}

export const validateTweetUrl = (url) => {
  const tweetPattern = /^(https?:\/\/)(www\.)?((twitter\.com|x\.com)\/(.*\/)?(status\/)?([^#]*))(#[\w]*)?$/
  if (tweetPattern.test(url)) {
    return url.split("/")[5].split("?")[0]
  }
  return null
}
