require "rails_helper"

RSpec.describe ArticleLanguage do
  let(:english) { "<p>#{'The quiet evening settled over the city and nobody spoke a word. ' * 2}</p>" }
  let(:arabic) { "<p>#{'كان المساء هادئاً فوق المدينة، ولم ينطق أحد بكلمة واحدة طوال الليل. ' * 2}</p>" }

  it "flags an article written in English" do
    expect(described_class.mostly_latin?("Silent Grief", english)).to be(true)
  end

  it "keeps Arabic articles, including ones full of technical English terms" do
    technical = "<p>نستخدم gRPC و Protocol Buffers لأن الـ API أسرع، والـ service بتتكلم مع الـ client مباشرة.</p>"

    expect(described_class.mostly_latin?("مساء", arabic)).to be(false)
    expect(described_class.mostly_latin?("عن gRPC", "#{arabic}#{technical}")).to be(false)
  end

  it "needs more than a title or a few English words" do
    expect(described_class.mostly_latin?("Hello world", "<p>Short note</p>")).to be(false)
  end

  it "ignores code, links and email addresses" do
    code = "<pre>#{'def call; render json: payload; end ' * 5}</pre>"
    links = "<p>https://example.com/a-very-long-english-path-name-here reader@example.com</p>"

    expect(described_class.mostly_latin?("ملاحظة", "#{arabic}#{code}#{links}")).to be(false)
  end

  it "classifies articles when they're saved" do
    article = create(:article, title: "Lies", content_html: english)
    expect(article).to be_mostly_latin

    article.update!(content_html: arabic, title: "أكاذيب")
    expect(article.reload).not_to be_mostly_latin
  end
end
