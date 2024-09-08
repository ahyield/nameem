// Description: This file contains the functions that interact with the article API.


async function fetchArticle(uuid, slug) {
  const response = await fetch(`/api/articles/${slug}/${uuid}/edit`, { method: "GET" })

  const data = await response.json()
  return data
}

async function newArticle() {
  const response = await fetch("/api/articles/new", { method: "GET" })

  const data = await response.json()
  return data
}

async function updateArticleTitle(uuid, slug, editor) {
  const articleTitle = document.getElementById("article-title").value

  const response = await fetch(`/api/articles/${slug}/${uuid}`, {
    method: "PUT",
    body: JSON.stringify({ article: { title: articleTitle, content: editor.getContents(), }}),
    headers: {
      "CONTENT-TYPE": "application/json",
    }
  })
  const article = await response.json()
  return article
}

async function updateArticleContent(uuid, slug, editor) {
  const response = await fetch(`/api/articles/${slug}/${uuid}`, {
    method: "PUT",
    body: JSON.stringify({ article: { content: editor.getContents(), }}),
    headers: {
      "CONTENT-TYPE": "application/json",
    }
  })
  const article = await response.json()
  return article
}

export { fetchArticle, newArticle, updateArticleTitle, updateArticleContent }
