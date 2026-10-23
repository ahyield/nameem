require "rails_helper"

RSpec.describe User do
  describe "validations" do
    context "when email is invalid" do
      it "is invalid with empty email" do
        expect(described_class.new(email: "")).not_to be_valid
      end

      it "is invalid with malformed emails" do
        invalid_emails = ["test", "test@", "test@test."]
        invalid_emails.each do |invalid_email|
          expect(described_class.new(email: invalid_email)).not_to be_valid
        end
      end
    end

    context "when email is valid" do
      it "is valid with proper email formats" do
        valid_emails = ["test@test.com", "TEST@TEST.com"]
        valid_emails.each do |valid_email|
          expect(described_class.new(email: valid_email)).to be_valid
        end
      end
    end

    context "when slug is invalid" do
      let(:valid_email) { "test@test.com" }

      it "is invalid with empty slug" do
        expect(described_class.new(email: valid_email, slug: "")).not_to be_valid
      end

      it "is invalid with reserved slug names" do
        expect(described_class.new(email: valid_email, slug: "backoffice")).not_to be_valid
      end
    end

    context "when slug is valid" do
      let(:valid_email) { "test@test.com" }

      it "is valid with proper slug formats" do
        valid_slugs = %w[test test-1 test_1]
        valid_slugs.each do |valid_slug|
          expect(described_class.new(email: valid_email, slug: valid_slug)).to be_valid
        end
      end
    end
  end

  describe "callbacks" do
    it "creates a user with default slug if none is provided" do
      user = create(:user, email: "test@test.com", slug: nil)
      expect(user.slug).to eq("test-test-com")
    end

    it "creates a user with custom slug" do
      user = create(:user, email: "test@test.com", slug: "test")
      expect(user.slug).to eq("test")
    end

    it "normalizes the email to lowercase" do
      user = create(:user, email: "TEST@TEST.com")
      expect(user.email).to eq("test@test.com")
    end
  end

  describe "attachments" do
    context "when avatar is attached" do
      it "has an attached avatar" do
        user = create(:user, :with_avatar)
        expect(user.avatar).to be_attached
      end
    end

    context "when avatar is not attached" do
      it "has no avatar by default" do
        user = create(:user, email: "test@test.com")
        user.avatar = nil
        expect(user.avatar).not_to be_attached
      end
    end
  end

  describe "associations" do
    it "has many articles" do
      user = create(:user, :with_articles)
      expect(user.articles.size).to eq(5)
    end

    it "has many sessions" do
      user = create(:user)
      create(:session, user: user)
      expect(user.sessions.count).to eq(1)
    end

    it "destroys sessions when user is destroyed" do
      user = create(:user)
      create(:session, user: user)
      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it "has many article_likes" do
      user = create(:user)
      article = create(:article, user: create(:user))
      create(:article_like, user: user, article: article)
      expect(user.article_likes.count).to eq(1)
    end

    it "has many liked_articles through article_likes" do
      user = create(:user)
      article = create(:article, user: create(:user))
      create(:article_like, user: user, article: article)
      expect(user.liked_articles).to include(article)
    end

    it "destroys article_likes when user is destroyed" do
      user = create(:user)
      article = create(:article, user: create(:user))
      create(:article_like, user: user, article: article)
      expect { user.destroy }.to change(ArticleLike, :count).by(-1)
    end

    it "has many comments" do
      user = create(:user)
      article = create(:article, user: create(:user))
      create(:comment, user: user, article: article)
      expect(user.comments.count).to eq(1)
    end

    it "destroys comments when user is destroyed" do
      user = create(:user)
      article = create(:article, user: create(:user))
      create(:comment, user: user, article: article)
      expect { user.destroy }.to change(Comment, :count).by(-1)
    end

    it "has many magic_links" do
      user = create(:user)
      create(:magic_link, user: user)
      expect(user.magic_links.count).to eq(1)
    end

    it "destroys magic_links when user is destroyed" do
      user = create(:user)
      create(:magic_link, user: user)
      expect { user.destroy }.to change(MagicLink, :count).by(-1)
    end
  end

  describe "#send_magic_link" do
    it "creates a magic link and enqueues the mailer" do
      user = create(:user)

      expect do
        user.send_magic_link(purpose: :sign_in)
      end.to change(MagicLink, :count).by(1)

      magic_link = user.magic_links.last
      expect(magic_link).to be_sign_in
    end
  end

  describe "features" do
    let(:user) { create(:user, email: "test@test.com", avatar: nil) }

    it "can be featured" do
      user.feature
      expect(user.featured).to be_truthy
    end

    it "can be admin" do
      user.make_admin
      expect(user).to be_admin
    end

    it "can be editor" do
      user.make_editor
      expect(user).to be_editor
    end
  end

  describe "profile links" do
    let(:user) { build(:user) }

    it "rejects non-http website URLs" do
      %w[javascript:alert(1) JaVaScRiPt:alert(1) data:text/html,x].each do |url|
        user.website_url = url
        expect(user).not_to be_valid
        expect(user.website_link).to be_nil
      end
    end

    it "adds https:// to a website without a scheme" do
      user.website_url = "nameem.com"
      expect(user.website_url).to eq("https://nameem.com")
      expect(user.website_link).to eq("https://nameem.com")
    end

    it "never links an unsafe website saved before validation existed" do
      user.save!
      user.update_column(:website_url, "javascript:alert(1)")
      expect(user.reload.website_link).to be_nil
    end

    it "stores handles without @, profile URLs or query strings" do
      user.twitter_handle = "@nameem"
      user.instagram_handle = "https://www.instagram.com/nameem?igsh=abc"
      expect(user.twitter_handle).to eq("nameem")
      expect(user.instagram_handle).to eq("nameem")
      expect(user.social_link(:instagram_handle)).to eq("https://instagram.com/nameem")
    end

    it "rejects handles with unsafe characters" do
      user.twitter_handle = "evil\"><script>"
      expect(user).not_to be_valid
      expect(user.social_link(:twitter_handle)).to be_nil
    end
  end

  describe "suspension" do
    let(:user) { create(:user) }

    it "suspends and lifts it" do
      user.suspend!("إساءة")
      expect(user).to be_suspended
      expect(described_class.suspended).to include(user)

      user.unsuspend!
      expect(user.reload).not_to be_suspended
      expect(user.suspension_reason).to be_nil
    end
  end

  describe ".suggested_for" do
    let(:reader) { create(:user) }

    def writer(*traits, followers: 0)
      create(:user, *traits, followers_count: followers).tap { |user| create(:article, :published, user:) }
    end

    it "prefers picked, then featured, then the most-followed writers" do
      picked = create(:user, :picked)
      featured = create(:user, :featured)
      popular = writer(followers: 50)
      writer(followers: 5)

      expect(described_class.suggested_for(reader, limit: 3)).to eq([picked, featured, popular])
    end

    it "skips the reader, people they follow, and writers without published articles" do
      followed = create(:user, :picked)
      create(:follow, follower: reader, followable: followed)
      create(:user, followers_count: 99)
      reader.update!(picked: true)

      expect(described_class.suggested_for(reader)).to be_empty
    end

    it "never suggests the same writer twice" do
      both = create(:user, :picked, :featured)
      writer(followers: 10)

      expect(described_class.suggested_for(reader).count(both)).to eq(1)
    end
  end
end
