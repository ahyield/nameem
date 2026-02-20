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
      expect(described_class.actions).to eq("liked" => 0, "commented" => 1, "featured" => 2, "picked" => 3, "followed" => 4)
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
end
