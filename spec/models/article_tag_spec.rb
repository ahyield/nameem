require "rails_helper"

RSpec.describe ArticleTag do
  describe "associations" do
    it "belongs to an article" do
      article_tag = create(:article_tag)
      expect(article_tag.article).to be_a(Article)
    end

    it "belongs to a tag" do
      article_tag = create(:article_tag)
      expect(article_tag.tag).to be_a(Tag)
    end
  end

  describe "validations" do
    it "prevents duplicate tag on the same article" do
      article_tag = create(:article_tag)
      duplicate = build(:article_tag, article: article_tag.article, tag: article_tag.tag)
      expect(duplicate).not_to be_valid
    end
  end

  describe "counter cache" do
    it "increments articles_count on tag when created" do
      tag = create(:tag)
      expect do
        create(:article_tag, tag: tag)
      end.to change { tag.reload.articles_count }.from(0).to(1)
    end

    it "decrements articles_count on tag when destroyed" do
      article_tag = create(:article_tag)
      tag = article_tag.tag
      expect do
        article_tag.destroy
      end.to change { tag.reload.articles_count }.by(-1)
    end
  end
end
