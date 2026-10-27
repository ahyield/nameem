require "rails_helper"

RSpec.describe ArticleSeoHelper do
  it "titles an untitled article by its opening line" do
    article = build(:article, title: nil, content_html: "<p>مطلع المقال</p>")

    expect(helper.article_seo_title(article)).to eq("مطلع المقال")
    expect(helper.article_seo_title(build(:article, title: nil, content_html: nil))).to be_nil
  end

  it "marks mostly-English articles as English" do
    expect(helper.article_language(build(:article, mostly_latin: true))).to eq("en")
    expect(helper.article_language(build(:article, mostly_latin: false))).to eq("ar")
  end

  it "cuts a long description at a word" do
    article = build(:article, description: "كلمة " * 50)

    expect(helper.article_seo_description(article)).to end_with("كلمة…")
  end
end
