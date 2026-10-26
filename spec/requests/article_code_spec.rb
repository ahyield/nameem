require "rails_helper"

RSpec.describe "Code in articles" do
  it "keeps code blocks and inline code when the article is shown" do
    html = '<p>استخدم <code class="editor-inline-code">git status</code> أولاً.</p>' \
           '<pre class="editor-code" spellcheck="false"><span>def hi</span><br><span>  puts 1</span></pre>'
    article = create(:article, :published, content_html: html)

    get user_article_path(slug: article.user.slug, uuid: article.uuid)

    expect(response.body).to include('<code class="editor-inline-code">git status</code>')
    expect(response.body).to include('<pre class="editor-code"><span>def hi</span><br><span>  puts 1</span></pre>')
    expect(response.body).to include('data-controller="tweet-embed code-copy"')
  end
end
