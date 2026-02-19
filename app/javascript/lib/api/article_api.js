function csrfToken() {
  return document.querySelector("meta[name=\"csrf-token\"]")?.content
}

async function request(url, options = {}) {
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    ...options,
  })
  if (!response.ok) throw new Error(`API ${response.status}`)
  return response.json()
}

export async function createArticle() {
  return request("/api/articles", { method: "POST" })
}

export async function fetchArticle(uuid, slug) {
  return request(`/api/articles/${slug}/${uuid}/edit`)
}

export async function saveArticle(uuid, slug, { title, content, content_html } = {}) {
  const article = {}
  if (title !== undefined) article.title = title
  if (content !== undefined) article.content = content
  if (content_html !== undefined) article.content_html = content_html
  return request(`/api/articles/${slug}/${uuid}`, {
    method: "PUT",
    body: JSON.stringify({ article }),
  })
}
