require "rails_helper"

RSpec.describe Article, ".related_to" do
  let(:author) { create(:user) }
  let(:tech_tag) { create(:tag, name: "تقنية") }
  let(:programming_tag) { create(:tag, name: "برمجة") }
  let(:design_tag) { create(:tag, name: "تصميم") }

  let(:article) do
    create(:article, :published, user: author).tap do |a|
      create(:article_tag, article: a, tag: tech_tag)
      create(:article_tag, article: a, tag: programming_tag)
    end
  end

  it "returns articles sharing tags with the given article" do
    related = create(:article, :published, user: create(:user))
    create(:article_tag, article: related, tag: tech_tag)

    expect(described_class.related_to(article)).to include(related)
  end

  it "excludes the article itself" do
    expect(described_class.related_to(article)).not_to include(article)
  end

  it "orders by shared tag count descending" do
    one_tag = create(:article, :published, user: create(:user))
    create(:article_tag, article: one_tag, tag: tech_tag)

    two_tags = create(:article, :published, user: create(:user))
    create(:article_tag, article: two_tags, tag: tech_tag)
    create(:article_tag, article: two_tags, tag: programming_tag)

    results = described_class.related_to(article)
    expect(results.first).to eq(two_tags)
    expect(results.second).to eq(one_tag)
  end

  it "respects the limit" do
    4.times do
      a = create(:article, :published, user: create(:user))
      create(:article_tag, article: a, tag: tech_tag)
    end

    expect(described_class.related_to(article, limit: 2).to_a.size).to eq(2)
  end

  it "returns empty when article has no tags" do
    no_tags = create(:article, :published, user: author)

    expect(described_class.related_to(no_tags)).to be_empty
  end

  it "only returns published articles" do
    draft = create(:article, :draft, user: create(:user))
    create(:article_tag, article: draft, tag: tech_tag)

    published = create(:article, :published, user: create(:user))
    create(:article_tag, article: published, tag: tech_tag)

    results = described_class.related_to(article)
    expect(results).to include(published)
    expect(results).not_to include(draft)
  end

  it "does not return articles with no shared tags" do
    unrelated = create(:article, :published, user: create(:user))
    create(:article_tag, article: unrelated, tag: design_tag)

    expect(described_class.related_to(article)).not_to include(unrelated)
  end
end
