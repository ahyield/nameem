require "rails_helper"

RSpec.describe "Article Analytics" do
  let(:author) { create(:user) }
  let(:article) { create(:article, :published, user: author, real_views_count: 42) }

  def article_path
    "/#{author.slug}/#{article.uuid}"
  end

  describe "visibility" do
    it "shows analytics modal and dropdown link to the author" do
      authenticate_user(author)
      get article_path
      expect(response.body).to include("article-analytics")
      expect(response.body).to include("إحصائيات")
      expect(response.body).to include("المشاهدات")
      expect(response.body).to include("الإعجابات")
      expect(response.body).to include("التعليقات")
    end

    it "shows analytics modal to an admin" do
      admin = create(:admin)
      authenticate_user(admin)
      get article_path
      expect(response.body).to include("article-analytics")
      expect(response.body).to include("إحصائيات")
    end

    it "shows analytics modal to an editor" do
      editor = create(:editor)
      authenticate_user(editor)
      get article_path
      expect(response.body).to include("article-analytics")
      expect(response.body).to include("إحصائيات")
    end

    it "does not show analytics to a regular reader" do
      reader = create(:user)
      authenticate_user(reader)
      get article_path
      expect(response.body).not_to include("article-analytics")
      expect(response.body).not_to include("إحصائيات المقال")
    end

    it "does not show analytics to anonymous visitors" do
      get article_path
      expect(response.body).not_to include("article-analytics")
      expect(response.body).not_to include("إحصائيات المقال")
    end
  end

  describe "content" do
    before { authenticate_user(author) }

    it "displays the views count" do
      get article_path
      expect(response.body).to include("42")
    end

    it "displays liker avatars" do
      liker = create(:user, first_name: "أحمد")
      create(:article_like, article: article, user: liker)

      get article_path
      expect(response.body).to include(liker.name)
    end

    it "displays commenter avatars" do
      commenter = create(:user, first_name: "سارة")
      create(:comment, article: article, user: commenter)

      get article_path
      expect(response.body).to include(commenter.name)
    end

    it "lists all likers in scrollable list" do
      likers = Array.new(8) { create(:user) }
      likers.each { |u| create(:article_like, article: article, user: u) }

      get article_path
      likers.each { |u| expect(response.body).to include(u.name) }
      expect(response.body).to include("أعجبهم المقال")
    end
  end
end
