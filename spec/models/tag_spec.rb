require "rails_helper"

RSpec.describe Tag do
  describe "validations" do
    it "requires a name" do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
    end

    it "requires a unique name" do
      create(:tag, name: "تقنية")
      duplicate = build(:tag, name: "تقنية")
      expect(duplicate).not_to be_valid
    end

    it "requires a unique slug" do
      create(:tag, name: "تقنية")
      duplicate = build(:tag, name: "تقنية")
      duplicate.validate
      expect(duplicate.errors[:slug]).to be_present
    end
  end

  describe "slug generation" do
    it "sets slug from name" do
      tag = create(:tag, name: "تقنية")
      expect(tag.slug).to eq("تقنية")
    end

    it "strips whitespace from slug" do
      tag = create(:tag, name: "  تقنية  ")
      expect(tag.slug).to eq("تقنية")
    end
  end

  describe "scopes" do
    it ".popular orders by articles_count desc" do
      create(:tag, articles_count: 1)
      tag_high = create(:tag, articles_count: 10)
      expect(described_class.popular.first).to eq(tag_high)
    end

    it ".with_articles excludes tags with zero articles" do
      tag_with = create(:tag, articles_count: 1)
      tag_without = create(:tag, articles_count: 0)
      expect(described_class.with_articles).to include(tag_with)
      expect(described_class.with_articles).not_to include(tag_without)
    end
  end

  describe "associations" do
    it "has many articles through article_tags" do
      tag = create(:tag)
      article = create(:article)
      create(:article_tag, tag: tag, article: article)
      expect(tag.articles).to include(article)
    end
  end

  describe "#to_param" do
    it "returns slug" do
      tag = create(:tag, name: "تقنية")
      expect(tag.to_param).to eq("تقنية")
    end
  end
end
