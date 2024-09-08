function isNewArticle() {
  const path = window.location.pathname
  if (path === "/new-story") {
    return true
  } else {
    return false
  }
}

function articleUuid() {
  const uuid = window.location.pathname.split("/")[2]
  return uuid
}

function userSlug() {
  const slug = window.location.pathname.split("/")[1]
  return slug
}

function drawUrl(data) {
  const url = window.location.origin + `/${data.user.slug}/${data.article.uuid}/edit`
  window.history.pushState(null, null, url)
}

function getImgUrls(delta) {
  return delta.ops.filter(i => i.insert && i.insert.customImage).map(i => i.insert.customImage)
}

export { isNewArticle, articleUuid, userSlug, drawUrl, getImgUrls }
