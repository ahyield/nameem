require "rails_helper"

RSpec.describe "Article.related_to" do
  let(:author) { create(:user) }
  let(:tag1) { create(:tag, name: "تقنية") }
  let(:tag2) { create(:tag, name: "برمجة") }
  let(:tag3) { create(:tag, name: "تصميم") }

  let(:article) do
    create(:article, :published, user: author).tap do |a|
      create(:article_tag, article: a, tag: tag1)
      create(:article_tag, article: a, tag: tag2)
    end
  end

  it "returns articles sharing tags with the given article" do
    related = create(:article, :published, user: create(:user))
    create(:article_tag, article: related, tag: tag1)

    expect(Article.related_to(article)).to include(related)
  end

  it "excludes the article itself" do
    expect(Article.related_to(article)).not_to include(article)
  end

  it "orders by shared tag count descending" do
    one_tag = create(:article, :published, user: create(:user))
    create(:article_tag, article: one_tag, tag: tag1)

    two_tags = create(:article, :published, user: create(:user))
    create(:article_tag, article: two_tags, tag: tag1)
    create(:article_tag, article: two_tags, tag: tag2)

    results = Article.related_to(article)
    expect(results.first).to eq(two_tags)
    expect(results.second).to eq(one_tag)
  end

  it "respects the limit" do
    4.times do
      a = create(:article, :published, user: create(:user))
      create(:article_tag, article: a, tag: tag1)
    end

    expect(Article.related_to(article, limit: 2).to_a.size).to eq(2)
  end

  it "returns empty when article has no tags" do
    no_tags = create(:article, :published, user: author)

    expect(Article.related_to(no_tags)).to be_empty
  end

  it "only returns published articles" do
    draft = create(:article, :draft, user: create(:user))
    create(:article_tag, article: draft, tag: tag1)

    published = create(:article, :published, user: create(:user))
    create(:article_tag, article: published, tag: tag1)

    results = Article.related_to(article)
    expect(results).to include(published)
    expect(results).not_to include(draft)
  end

  it "does not return articles with no shared tags" do
    unrelated = create(:article, :published, user: create(:user))
    create(:article_tag, article: unrelated, tag: tag3)

    expect(Article.related_to(article)).not_to include(unrelated)
  end
end
