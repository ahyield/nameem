require "rails_helper"

RSpec.describe Comment do
  describe "associations" do
    it "belongs to an article" do
      comment = create(:comment)
      expect(comment.article).to be_a(Article)
    end

    it "belongs to a user" do
      comment = create(:comment)
      expect(comment.user).to be_a(User)
    end

    it "has rich text body" do
      comment = create(:comment, body: "تعليق جميل")
      expect(comment.body.to_plain_text).to eq("تعليق جميل")
    end
  end

  describe "validations" do
    it "is invalid without a body" do
      comment = build(:comment, body: nil)
      expect(comment).not_to be_valid
    end

    it "is valid with a body" do
      comment = build(:comment, body: "تعليق")
      expect(comment).to be_valid
    end
  end

  describe "counter cache" do
    it "increments comments_count on article when created" do
      article = create(:article)
      expect {
        create(:comment, article: article)
      }.to change { article.reload.comments_count }.by(1)
    end

    it "decrements comments_count on article when destroyed" do
      article = create(:article)
      comment = create(:comment, article: article)
      expect {
        comment.destroy
      }.to change { article.reload.comments_count }.by(-1)
    end
  end
end
