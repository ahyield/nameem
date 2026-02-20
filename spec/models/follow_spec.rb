require "rails_helper"

RSpec.describe Follow do
  describe "associations" do
    it "belongs to a follower (User)" do
      follow = create(:follow)
      expect(follow.follower).to be_a(User)
    end

    it "belongs to a followable (polymorphic)" do
      follow = create(:follow)
      expect(follow.followable).to be_a(User)
    end

    it "can follow a tag" do
      follow = create(:follow, :tag_follow)
      expect(follow.followable).to be_a(Tag)
    end
  end

  describe "validations" do
    it "prevents duplicate follows" do
      follow = create(:follow)
      duplicate = build(:follow, follower: follow.follower, followable: follow.followable)

      expect(duplicate).not_to be_valid
    end

    it "prevents self-follow for users" do
      user = create(:user)
      follow = build(:follow, follower: user, followable: user)

      expect(follow).not_to be_valid
      expect(follow.errors[:follower_id]).to include("can't follow yourself")
    end

    it "allows following a different user" do
      follower = create(:user)
      followed = create(:user)
      follow = build(:follow, follower: follower, followable: followed)

      expect(follow).to be_valid
    end
  end

  describe "counter caches" do
    it "increments followers_count on the followed user" do
      followed = create(:user)
      expect {
        create(:follow, followable: followed)
      }.to change { followed.reload.followers_count }.by(1)
    end

    it "decrements followers_count on unfollow" do
      follow = create(:follow)
      followed = follow.followable

      expect {
        follow.destroy
      }.to change { followed.reload.followers_count }.by(-1)
    end

    it "increments following_count on the follower" do
      follower = create(:user)
      expect {
        create(:follow, follower: follower)
      }.to change { follower.reload.following_count }.by(1)
    end

    it "decrements following_count on unfollow" do
      follow = create(:follow)
      follower = follow.follower

      expect {
        follow.destroy
      }.to change { follower.reload.following_count }.by(-1)
    end

    it "increments followers_count on a followed tag" do
      tag = create(:tag)
      expect {
        create(:follow, :tag_follow, followable: tag)
      }.to change { tag.reload.followers_count }.by(1)
    end

    it "decrements followers_count on tag unfollow" do
      follow = create(:follow, :tag_follow)
      tag = follow.followable

      expect {
        follow.destroy
      }.to change { tag.reload.followers_count }.by(-1)
    end
  end

  describe "notifications" do
    it "creates a notification when following a user" do
      expect {
        create(:follow)
      }.to change(Notification, :count).by(1)
    end

    it "creates a followed notification with correct attributes" do
      follow = create(:follow)
      notification = Notification.last

      expect(notification.recipient).to eq(follow.followable)
      expect(notification.actor).to eq(follow.follower)
      expect(notification.action).to eq("followed")
      expect(notification.notifiable).to eq(follow)
    end

    it "does not create a notification when following a tag" do
      expect {
        create(:follow, :tag_follow)
      }.not_to change(Notification, :count)
    end
  end
end
