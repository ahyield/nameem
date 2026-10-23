require "rails_helper"

RSpec.describe "Writing an article" do
  let(:author) { create(:user) }

  it "drafts in the editor, autosaves, and publishes" do
    system_sign_in(author)
    visit "/new-story"

    fill_in "article-title", with: "رحلة إلى البحر"
    # Saving the title creates the article and moves the URL to its edit page
    expect(page).to have_current_path(%r{/#{author.slug}/[0-9a-f-]{36}/edit}, wait: 10)

    find(".editor-container[contenteditable='true']").click
    find(".editor-container[contenteditable='true']").send_keys("كانت الأمواج عالية والسماء صافية.")
    expect(page).to have_content("تم الحفظ", wait: 10)

    article = author.articles.last
    expect(article.title).to eq("رحلة إلى البحر")
    expect(article.content_html).to include("كانت الأمواج عالية")
    expect(article).not_to be_published

    click_on "نشر"
    within("turbo-frame#modal") { click_on "نشر" }

    expect(page).to have_current_path("/#{author.slug}/#{article.uuid}")
    expect(page).to have_content("رحلة إلى البحر")
    expect(page).to have_content("كانت الأمواج عالية والسماء صافية.")
    expect(article.reload).to be_published
  end
end
