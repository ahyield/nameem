require "rails_helper"

RSpec.describe RelatedArticles do
  # InnoDB full-text indexes only see committed rows, so these examples run outside a transaction
  self.use_transactional_tests = false

  after do
    [ArticleTag, Tag, PageView, Article, Session, User].each(&:delete_all)
  end

  let(:author) { create(:user) }

  def published(text, user: create(:user), title: nil, **attributes)
    create(:article, :published, user:, title: title || text.split.first(3).join(" "),
                                 description: nil, content_html: "<p>#{text}</p>", **attributes)
  end

  # Natural-language full-text search ignores words found in half the rows or more, so add unrelated articles
  before do
    %w[طبخ رياضة سفر برمجة موسيقى اقتصاد تاريخ].each do |topic|
      published("مقال عن #{topic} وأسراره المختلفة وتجارب الناس معه في الحياة اليومية")
    end
  end

  it "finds other writers' articles about the same thing" do
    article = published("الحنين إلى البيت القديم ورائحة الياسمين في الصباح", user: author)
    longing = published("رائحة الياسمين تعيدني إلى الحنين والبيت القديم")
    published("الحنين إلى البيت القديم ورائحة الياسمين", user: author)

    expect(described_class.for(article).first).to eq(longing)
    expect(described_class.for(article).map(&:user_id)).not_to include(author.id)
  end

  it "ranks shared topics higher among similar articles" do
    tag = Tag.create!(name: "شعر")
    article = published("قصيدة عن البحر والموج والسفن الراحلة", user: author)
    article.tags << tag
    plain = published("البحر والموج والسفن في قصيدة جديدة")
    tagged = published("السفن والبحر والموج في قصيدة")
    tagged.tags << tag

    expect(described_class.for(article).first(2)).to eq([tagged, plain])
  end

  # The other-language article shares the words, so only the language rule keeps it out; and there are enough
  # same-language matches that the any-language top-up never runs
  it "keeps to the article's language when matching text" do
    article = published("الحنين إلى البيت القديم ورائحة الياسمين", user: author)
    matches = Array.new(3) { published("رائحة الياسمين والحنين إلى البيت القديم") }
    other_language = published("الحنين إلى البيت القديم ورائحة الياسمين in a mostly English article")
    other_language.update_column(:mostly_latin, true)

    expect(described_class.for(article)).to match_array(matches)
  end

  it "doesn't top up when the text finds enough" do
    article = published("الحنين إلى البيت القديم ورائحة الياسمين", user: author)
    matches = Array.new(3) { published("رائحة الياسمين والحنين إلى البيت القديم") }
    published("موضوع رائج عن شيء مختلف تماماً", trending_rank: 1)

    expect(described_class.for(article)).to match_array(matches)
  end

  it "tops up with trending articles when the text finds too little" do
    article = published("كلمات نادرة جداً لا تتكرر أبداً زنجبيل", user: author)
    trending = published("موضوع رائج عن شيء مختلف تماماً", trending_rank: 1)

    expect(described_class.for(article)).to include(trending)
  end

  it "tops up with recent engaging articles, and handles an article with no words" do
    article = create(:article, :published, user: author, title: nil, description: nil, content_html: nil)
    popular = published("مقال قرأه كثيرون", likes_count: 9, published_at: 3.days.ago)

    expect(described_class.for(article)).to include(popular)
  end
end
