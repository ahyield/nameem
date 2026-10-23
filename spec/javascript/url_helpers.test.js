// @vitest-environment jsdom
import { afterEach, describe, expect, it } from "vitest"
import { articleUuid, drawUrl, isNewArticle, userSlug } from "../../app/javascript/lib/api/helpers/url_helpers.js"

const visit = (path) => window.history.pushState(null, null, path)

describe("url_helpers", () => {
  afterEach(() => visit("/"))

  it("knows when the editor is on a new story", () => {
    visit("/new-story")
    expect(isNewArticle()).toBe(true)

    visit("/someone/0a4f0016-d1ac-49c1-9d8c-322494dd596c/edit")
    expect(isNewArticle()).toBe(false)
  })

  it("reads the author slug and article UUID from the edit URL", () => {
    visit("/someone/0a4f0016-d1ac-49c1-9d8c-322494dd596c/edit")

    expect(userSlug()).toBe("someone")
    expect(articleUuid()).toBe("0a4f0016-d1ac-49c1-9d8c-322494dd596c")
  })

  it("moves a new story to its edit URL once it's created", () => {
    visit("/new-story")
    drawUrl({ user: { slug: "someone" }, article: { uuid: "abc" } })

    expect(window.location.pathname).toBe("/someone/abc/edit")
  })
})
