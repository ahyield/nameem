require "rails_helper"

RSpec.describe JsonLdHelper do
  let(:author) { create(:user) }

  describe "#article_json_ld" do
    it "describes the article with its cover image" do
      article = create(:article, :published, user: author, title: "عنوان", description: "وصف",
                                             content_html: '<p>نص</p><img src="https://example.com/cover.jpg">')

      data = helper.article_json_ld(article, author)

      expect(data).to include("@type" => "Article", "headline" => "عنوان", "description" => "وصف",
                              "image" => "https://example.com/cover.jpg")
      expect(data["author"]).to include("name" => author.name)
    end

    it "leaves out the image and description when there are none" do
      article = create(:article, :published, user: author, description: nil, content_html: nil)

      data = helper.article_json_ld(article, author)
      expect(data).not_to have_key("image")
      expect(data["description"]).to be_nil
    end
  end

  describe "#json_ld_tag" do
    it "can't be broken out of with a closing script tag in a title" do
      html = helper.json_ld_tag("headline" => "</script><script>alert(1)</script>")

      expect(html.scan("</script>").size).to eq(1)
      expect(html).to include("</script>")
    end
  end
end
