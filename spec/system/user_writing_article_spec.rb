require "rails_helper"

RSpec.describe "UserWritingArticle" do
  let(:user) { create(:user, email: "n@n.com") }

  before do
    authenticate_user user
  end

  describe "writing article" do
    it "writes article and publishes it" do
      visit root_path

      within("nav") do
        click_link(href: "/new-story")
      end

      sleep 2 # So the article can catch up with saving
      fill_in "article-title", with: "My first article"
      sleep 2 # So the article can catch up with saving
      find(".ql-editor").click
      sleep 2 # So the article can catch up with saving
      find(".ql-editor").set("This is my first article ")

      sleep 2 # So the article can catch up with saving

      click_button "نشر"

      expect(page).to have_content("معاينة الموضوع")

      within("turbo-frame#modal") do
        click_button "نشر"
      end

      expect(page).to have_content("This is my first article")
    end
  end
end
