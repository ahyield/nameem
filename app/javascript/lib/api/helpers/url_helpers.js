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

export { isNewArticle, articleUuid, userSlug, drawUrl }
