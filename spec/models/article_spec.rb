require "rails_helper"

RSpec.describe Article do
  let(:content) { JSON.parse(File.read("spec/fixtures/article.json")) }
  let(:article) { create(:article, title: "New Article", content:) }

  describe "attributes" do
    it "has a title" do
      expect(article.title).to eq("New Article")
    end

    it "has a body" do
      expect(article.content).to eq(content)
    end

    it "has a published date" do
      article = create(:article, title: "New Article", published_at: "2021-01-01")
      expect(article.published_at).to eq(Date.parse("2021-01-01"))
    end

    it "has a created date" do
      article = create(:article, title: "New Article", created_at: "2021-01-01")
      expect(article.created_at).to eq(Date.parse("2021-01-01"))
    end

    it "has an updated date" do
      article = create(:article, title: "New Article", updated_at: "2021-01-01")
      expect(article.updated_at).to eq(Date.parse("2021-01-01"))
    end

    it "has a slug" do
      article = create(:article, title: "New Article", slug: "new-article")
      expect(article.slug).to eq("new-article")
    end
  end

  describe "metable" do
    context "when updating content_html" do
      before do
        article.update(content_html: "<p>Updated Article</p>")
      end

      it "has a description" do
        expect(article.description).to eq("Updated Article")
      end

      it "has alternative titles" do
        sentence = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
        article = create(:article, title: nil, content_html: "<p>#{sentence}</p>")
        expect(article.alternative_titles).to eq([sentence])
      end

      it "has article images" do
        expect(article.article_images).to eq([])
      end

      it "extracts images from content_html" do
        article.update(content_html: '<p>text</p><figure><img src="https://example.com/photo.jpg"></figure>')
        expect(article.article_images).to eq(["https://example.com/photo.jpg"])
      end
    end

    describe "#update_reading_time" do
      it "calculates reading time from content_html on update" do
        words = (["كلمة"] * 400).join(" ")
        article.update(content_html: "<p>#{words}</p>")

        expect(article.reading_time_minutes).to eq(2)
      end

      it "returns 1 minute minimum for short content" do
        article.update(content_html: "<p>مرحبا بالعالم</p>")

        expect(article.reading_time_minutes).to eq(1)
      end

      it "strips HTML tags before counting words" do
        words = (["كلمة"] * 200).join(" ")
        article.update(content_html: "<h1>عنوان</h1><p><strong>#{words}</strong></p><blockquote>اقتباس</blockquote>")

        expect(article.reading_time_minutes).to eq(1)
      end

      it "ignores single-character words" do
        article.update(content_html: "<p>a b c d e f g h i j</p>")

        expect(article.reading_time_minutes).to eq(1)
      end

      it "rounds up to the nearest minute" do
        words = (["كلمة"] * 210).join(" ")
        article.update(content_html: "<p>#{words}</p>")

        expect(article.reading_time_minutes).to eq(2)
      end

      it "does not update reading time when content_html is blank" do
        article.update(content_html: nil)
        article.update(title: "New Title")

        expect(article.reading_time_minutes).to be_nil
      end

      it "handles content with images and embeds" do
        words = (["كلمة"] * 600).join(" ")
        html = "<p>#{words}</p><figure><img src=\"test.jpg\"></figure><div class=\"tweet-embed\" data-tweet-id=\"123\"></div>"
        article.update(content_html: html)

        expect(article.reading_time_minutes).to eq(3)
      end
    end
  end

  describe "associations" do
    it "has many comments" do
      article = create(:article)
      create(:comment, article: article)
      expect(article.comments.count).to eq(1)
    end

    it "destroys comments when article is destroyed" do
      article = create(:article)
      create(:comment, article: article)
      expect { article.destroy }.to change(Comment, :count).by(-1)
    end
  end

  describe "publishing" do
    it "can be published" do
      article.publish
      expect(article.published).to be true
    end

    it "can be unpublished" do
      article.unpublish
      expect(article.published).to be false
    end
  end

  describe "features" do
    it "can be picked" do
      article.pick
      expect(article.picked).to be true
    end

    it "can be featured" do
      article.feature
      expect(article.featured).to be true
    end
  end

  describe "notifications" do
    before { create(:user, id: 1) }

    it "creates a notification when featured" do
      expect do
        article.feature
      end.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.action).to eq("featured")
      expect(notification.recipient).to eq(article.user)
    end

    it "creates a notification when picked" do
      expect do
        article.pick
      end.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.action).to eq("picked")
      expect(notification.recipient).to eq(article.user)
    end

    it "does not create a notification when unfeatured" do
      article.update(featured: true)

      expect do
        article.update(featured: false)
      end.not_to change(Notification, :count)
    end

    it "does not create a notification when unpicked" do
      article.update(picked: true)

      expect do
        article.update(picked: false)
      end.not_to change(Notification, :count)
    end
  end
end
