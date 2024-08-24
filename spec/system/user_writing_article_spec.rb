require "rails_helper"

RSpec.describe "UserWritingArticle" do
  let(:user) { create(:user, email: "n@n.com") }

  before do
    authenticate_user user
  end

  describe "writing article" do
    it "user login with magiclink" do
      visit root_path
      expect(page).to have_content("الصفحة الشخصية")

      within("nav") do
        click_link(href: "/new-story")
      end

      fill_in "article-title", with: "My first article"
      fill_in ".ql-editor", with: "This is my first article"
      click_button "نشر"
    end
  end
end
