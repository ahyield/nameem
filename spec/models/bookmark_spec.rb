require "rails_helper"

RSpec.describe Bookmark do
  describe "associations" do
    it "belongs to an article" do
      bookmark = create(:bookmark)
      expect(bookmark.article).to be_a(Article)
    end

    it "belongs to a user" do
      bookmark = create(:bookmark)
      expect(bookmark.user).to be_a(User)
    end
  end

  describe "validations" do
    it "prevents duplicate bookmarks from the same user on the same article" do
      bookmark = create(:bookmark)
      duplicate = build(:bookmark, article: bookmark.article, user: bookmark.user)
      expect(duplicate).not_to be_valid
    end

    it "allows different users to bookmark the same article" do
      article = create(:article)
      create(:bookmark, article: article)
      bookmark = build(:bookmark, article: article)
      expect(bookmark).to be_valid
    end

    it "allows the same user to bookmark different articles" do
      user = create(:user)
      create(:bookmark, user: user)
      bookmark = build(:bookmark, user: user)
      expect(bookmark).to be_valid
    end
  end
end
