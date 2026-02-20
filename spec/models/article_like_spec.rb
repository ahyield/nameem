require "rails_helper"

RSpec.describe ArticleLike do
  describe "associations" do
    it "belongs to an article" do
      like = create(:article_like)
      expect(like.article).to be_a(Article)
    end

    it "belongs to a user" do
      like = create(:article_like)
      expect(like.user).to be_a(User)
    end
  end

  describe "validations" do
    it "prevents duplicate likes from the same user on the same article" do
      like = create(:article_like)
      duplicate = build(:article_like, article: like.article, user: like.user)
      expect(duplicate).not_to be_valid
    end
  end

  describe "notifications" do
    it "creates a notification when liker is not the author" do
      article = create(:article)
      liker = create(:user)

      expect do
        create(:article_like, article: article, user: liker)
      end.to change(Notification, :count).by(1)
    end

    it "does not create a notification on self-like" do
      article = create(:article)

      expect do
        create(:article_like, article: article, user: article.user)
      end.not_to change(Notification, :count)
    end

    it "creates a liked notification" do
      article = create(:article)
      liker = create(:user)
      like = create(:article_like, article: article, user: liker)

      notification = Notification.last
      expect(notification.action).to eq("liked")
      expect(notification.recipient).to eq(article.user)
      expect(notification.actor).to eq(liker)
      expect(notification.notifiable).to eq(like)
    end
  end

  describe "counter cache" do
    it "increments likes_count on article when created" do
      article = create(:article)
      expect do
        create(:article_like, article: article)
      end.to change { article.reload.likes_count }.from(0).to(1)
    end

    it "decrements likes_count on article when destroyed" do
      like = create(:article_like)
      article = like.article
      expect do
        like.destroy
      end.to change { article.reload.likes_count }.by(-1)
    end
  end
end
