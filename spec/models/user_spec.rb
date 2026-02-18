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
        user = create(:user)
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

      expect {
        user.send_magic_link(purpose: :sign_in)
      }.to change(MagicLink, :count).by(1)

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
end
