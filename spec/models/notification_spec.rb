require "rails_helper"

RSpec.describe Notification do
  describe "associations" do
    it "belongs to a recipient" do
      notification = create(:notification)
      expect(notification.recipient).to be_a(User)
    end

    it "belongs to an actor" do
      notification = create(:notification)
      expect(notification.actor).to be_a(User)
    end

    it "belongs to a notifiable" do
      notification = create(:notification)
      expect(notification.notifiable).to be_present
    end
  end

  describe "enums" do
    it "defines action enum" do
      expect(described_class.actions).to eq("liked" => 0, "commented" => 1, "featured" => 2, "picked" => 3, "followed" => 4,
                                            "replied" => 5, "comment_liked" => 6,
                                            "report_actioned" => 7, "content_removed" => 8)
    end
  end

  describe "scopes" do
    describe ".unread" do
      it "returns notifications without read_at" do
        unread = create(:notification)
        create(:notification, :read)

        expect(described_class.unread).to eq([unread])
      end
    end

    describe ".recent" do
      it "returns notifications ordered by created_at desc" do
        old = create(:notification, created_at: 2.days.ago)
        new_one = create(:notification, created_at: 1.hour.ago)

        expect(described_class.recent).to eq([new_one, old])
      end
    end
  end

  describe "#read?" do
    it "returns true when read_at is present" do
      notification = build(:notification, :read)
      expect(notification.read?).to be true
    end

    it "returns false when read_at is nil" do
      notification = build(:notification, read_at: nil)
      expect(notification.read?).to be false
    end
  end

  describe "#mark_as_read!" do
    it "sets read_at to current time" do
      notification = create(:notification)
      notification.mark_as_read!
      expect(notification.read_at).to be_within(1.second).of(Time.current)
    end

    it "does not update if already read" do
      notification = create(:notification, :read)
      original_read_at = notification.read_at

      notification.mark_as_read!
      expect(notification.read_at).to eq(original_read_at)
    end
  end

  describe "instant emails", :queued_jobs do
    let(:author) { create(:user) }
    let(:article) { create(:article, :published, user: author) }

    def comment_by(user = create(:user))
      create(:comment, article:, user:)
    end

    it "emails the author right away and marks the notification emailed" do
      expect { comment_by }.to have_enqueued_mail(ActivityMailer, :comment)
      expect(described_class.commented.last.emailed_at).to be_present
    end

    it "waits for the digest when the author was emailed about the same article minutes ago" do
      comment_by

      expect { comment_by }.not_to have_enqueued_mail(ActivityMailer, :comment)
      expect(described_class.commented.last.emailed_at).to be_nil
    end

    it "emails again once the cooldown has passed" do
      comment_by
      described_class.commented.last.update_column(:emailed_at, 20.minutes.ago)

      expect { comment_by }.to have_enqueued_mail(ActivityMailer, :comment)
    end

    it "respects the comments setting" do
      author.update!(email_comments: false)

      expect { comment_by }.not_to have_enqueued_mail(ActivityMailer, :comment)
      expect(described_class.commented.last.emailed_at).to be_nil
    end

    it "emails the author when their article is featured" do
      User.find_by(id: 1) || create(:user, id: 1) # featuring notifies from the site account
      expect { article.update!(featured: true) }.to have_enqueued_mail(ActivityMailer, :editorial)
    end

    it "sends nothing for likes and follows" do
      expect { create(:article_like, article:) }.not_to have_enqueued_mail
    end
  end
end
