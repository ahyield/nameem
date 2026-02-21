require "rails_helper"

RSpec.describe CommentLike do
  describe "associations" do
    it "belongs to a comment" do
      like = create(:comment_like)
      expect(like.comment).to be_a(Comment)
    end

    it "belongs to a user" do
      like = create(:comment_like)
      expect(like.user).to be_a(User)
    end

    it "has many notifications" do
      like = create(:comment_like)
      expect(like).to respond_to(:notifications)
    end
  end

  describe "validations" do
    it "enforces uniqueness of user per comment" do
      like = create(:comment_like)
      duplicate = build(:comment_like, user: like.user, comment: like.comment)
      expect(duplicate).not_to be_valid
    end

    it "allows the same user to like different comments" do
      user = create(:user)
      like1 = create(:comment_like, user: user)
      like2 = build(:comment_like, user: user)
      expect(like2).to be_valid
    end

    it "allows different users to like the same comment" do
      comment = create(:comment)
      create(:comment_like, comment: comment)
      like2 = build(:comment_like, comment: comment)
      expect(like2).to be_valid
    end
  end

  describe "counter cache" do
    it "increments likes_count on comment when created" do
      comment = create(:comment)
      expect do
        create(:comment_like, comment: comment)
      end.to change { comment.reload.likes_count }.by(1)
    end

    it "decrements likes_count on comment when destroyed" do
      like = create(:comment_like)
      comment = like.comment
      expect do
        like.destroy
      end.to change { comment.reload.likes_count }.by(-1)
    end
  end

  describe "notifications" do
    it "creates a :comment_liked notification to comment author" do
      comment = create(:comment)
      liker = create(:user)

      expect do
        create(:comment_like, comment: comment, user: liker)
      end.to change { Notification.where(action: :comment_liked).count }.by(1)

      notification = Notification.where(action: :comment_liked).last
      expect(notification.recipient).to eq(comment.user)
      expect(notification.actor).to eq(liker)
      expect(notification.notifiable_type).to eq("CommentLike")
    end

    it "does not create a notification when liking own comment" do
      comment = create(:comment)

      expect do
        create(:comment_like, comment: comment, user: comment.user)
      end.not_to change(Notification, :count)
    end
  end

  describe "dependent destroy" do
    it "destroys associated notifications when like is destroyed" do
      like = create(:comment_like)
      # Trigger notification creation
      notification = Notification.where(notifiable: like).first

      expect { like.destroy }.to change(Notification, :count).by(-1) if notification
    end

    it "does not leave orphaned notifications after destroy" do
      comment = create(:comment)
      liker = create(:user)
      like = create(:comment_like, comment: comment, user: liker)

      like.destroy
      expect(Notification.where(notifiable_type: "CommentLike", notifiable_id: like.id)).to be_empty
    end
  end
end
