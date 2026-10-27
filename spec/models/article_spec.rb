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

  describe "comments_enabled" do
    it "is on for new articles" do
      expect(described_class.new.comments_enabled).to be(true)
    end

    it { is_expected.to validate_inclusion_of(:comments_enabled).in_array([true, false]) }
  end

  describe "metable" do
    context "when updating content_html" do
      before do
        article.update_column(:description, nil)
        article.update(content_html: "<p>Updated Article</p>")
      end

      it "fills the description from the content" do
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

    describe "description" do
      let(:article) { create(:article, description: nil) }

      it "follows the content while the author hasn't written one" do
        article.update(content_html: "<p>البداية</p>")
        expect(article.description).to eq("البداية")

        article.update(content_html: "<p>البداية والمزيد</p>")
        expect(article.reload.description).to eq("البداية والمزيد")
      end

      it "keeps a description the author wrote through later edits" do
        article.update(content_html: "<p>البداية</p>")
        article.update(description: "وصف كتبه الكاتب")

        article.update(content_html: "<p>نص جديد تماماً</p>")
        expect(article.reload.description).to eq("وصف كتبه الكاتب")
      end

      it "puts a space between paragraphs and cuts a long opening at a word" do
        article.update(content_html: "<p>أحبه.</p><p>#{'كلام ' * 60}</p>")

        expect(article.description).to start_with("أحبه. كلام")
        expect(article.description).to end_with("كلام…")
        expect(article.description.length).to be <= Metable::SUMMARY_LENGTH
      end

      it "still follows the content when the description is an older, shorter summary" do
        long = "<p>#{'كلمة ' * 40}</p>"
        article.update_columns(content_html: long, description: Nokogiri::HTML.fragment(long).text.squish.truncate(100))

        article.update(content_html: "<p>نص جديد</p>")
        expect(article.description).to eq("نص جديد")
      end

      it "keeps a description written in the same save as the content" do
        article.update(content_html: "<p>نص</p>", description: "وصف خاص")
        expect(article.reload.description).to eq("وصف خاص")
      end

      it "saves derived fields in a single UPDATE" do
        updates = []
        callback = ->(*, payload) { updates << payload[:sql] if payload[:sql].start_with?("UPDATE `articles`") }
        ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
          article.update(content_html: "<p>نص المقال</p>")
        end

        expect(updates.size).to eq(1)
      end
    end

    describe "reading time" do
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

  describe ".backfill_seo" do
    let(:long) { "<p>#{'كلمة ' * 40}</p>" }

    it "gives older articles a slug and a fuller summary without touching updated_at" do
      article = create(:article, :published, title: "قديم")
      legacy = Nokogiri::HTML.fragment(long).text.squish.truncate(100)
      article.update_columns(slug: nil, content_html: long, description: legacy, updated_at: 1.year.ago)

      expect { described_class.backfill_seo }.not_to(change { article.reload.updated_at })
      expect(article.slug).to eq("قديم")
      expect(article.description).to end_with("…")
    end

    it "leaves descriptions authors wrote and articles that are up to date" do
      written = create(:article, :published)
      written.update_columns(content_html: long, description: "وصف كتبه الكاتب")
      current = create(:article, :published, content_html: long)

      expect(described_class.backfill_seo).to eq(0)
      expect(written.reload.description).to eq("وصف كتبه الكاتب")
      expect(current.reload.slug).to eq("new-article")
    end
  end
end
