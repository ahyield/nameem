require "rails_helper"

RSpec.describe "Following, commenting and bookmarking" do
  let(:author) { create(:user) }
  let(:reader) { create(:user) }
  let!(:article) do
    create(:article, :published, user: author, title: "عن المطر", content_html: "<p>نص المقال عن المطر.</p>")
  end

  before { system_sign_in(reader) }

  it "follows an author and the count updates in place" do
    visit user_path(author)
    within("##{ActionView::RecordIdentifier.dom_id(author, :followers_count)}") { expect(page).to have_content("0") }

    click_on "متابعة"

    expect(page).to have_button("إلغاء المتابعة")
    within("##{ActionView::RecordIdentifier.dom_id(author, :followers_count)}") { expect(page).to have_content("1") }
    expect(author.reload.followers_count).to eq(1)
  end

  it "comments on an article" do
    visit "/#{author.slug}/#{article.uuid}"
    find("button[data-action='drawer#open']").click # comments live in a side drawer

    within("[role='dialog'][aria-label='التعليقات']") do
      find("trix-editor").click.set("مقال جميل، شكرًا")
      click_on "تعليق"
      expect(page).to have_content("مقال جميل، شكرًا")
    end
    expect(article.comments.last.body.to_plain_text).to eq("مقال جميل، شكرًا")
  end

  it "bookmarks an article" do
    visit "/#{author.slug}/#{article.uuid}"

    find("form[action='/#{author.slug}/#{article.uuid}/bookmark'] button", match: :first).click

    expect(page).to have_css("form[action='/#{author.slug}/#{article.uuid}/bookmark'][method='post'] input[value='delete']",
                             visible: :all)
    expect(reader.bookmarks.where(article:)).to exist
  end
end
