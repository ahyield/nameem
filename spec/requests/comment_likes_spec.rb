require "rails_helper"

RSpec.describe "Comment Likes" do
  let(:author) { create(:user) }
  let(:article) { create(:article, :published, user: author) }
  let(:comment) { create(:comment, article: article, user: author) }
  let(:liker) { create(:user) }

  describe "POST /:slug/:uuid/comments/:id/like" do
    before { authenticate_user(liker) }

    it "creates a comment like" do
      expect do
        post user_like_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream
      end.to change(CommentLike, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "increments the likes_count on the comment" do
      expect do
        post user_like_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream
      end.to change { comment.reload.likes_count }.by(1)
    end

    it "creates a :comment_liked notification" do
      expect do
        post user_like_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream
      end.to change { Notification.where(action: :comment_liked).count }.by(1)

      notification = Notification.where(action: :comment_liked).last
      expect(notification.recipient).to eq(author)
      expect(notification.actor).to eq(liker)
      expect(notification.notifiable_type).to eq("CommentLike")
    end

    it "does not allow liking own comment" do
      authenticate_user(author)

      expect do
        post user_like_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream
      end.not_to change(CommentLike, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not create duplicate likes" do
      create(:comment_like, comment: comment, user: liker)

      expect do
        post user_like_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream
      end.not_to change(CommentLike, :count)
    end

    it "does not create notification when liking own comment" do
      own_comment = create(:comment, article: article, user: liker)

      expect do
        post user_like_comment_path(slug: author, uuid: article, id: own_comment),
             as: :turbo_stream
      end.not_to change(Notification, :count)
    end

    it "can like a reply (not just top-level comments)" do
      parent = create(:comment, article: article, user: author)
      reply = create(:comment, article: article, user: author, parent: parent)

      expect do
        post user_like_comment_path(slug: author, uuid: article, id: reply),
             as: :turbo_stream
      end.to change(CommentLike, :count).by(1)

      expect(CommentLike.last.comment).to eq(reply)
    end

    it "notifies the reply author when their reply is liked" do
      reply_author = create(:user)
      parent = create(:comment, article: article, user: author)
      reply = create(:comment, article: article, user: reply_author, parent: parent)

      post user_like_comment_path(slug: author, uuid: article, id: reply),
           as: :turbo_stream

      notification = Notification.where(action: :comment_liked).last
      expect(notification.recipient).to eq(reply_author)
    end

  end

  describe "DELETE /:slug/:uuid/comments/:id/like" do
    before { authenticate_user(liker) }

    it "removes a comment like" do
      create(:comment_like, comment: comment, user: liker)

      expect do
        delete user_unlike_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change(CommentLike, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "decrements the likes_count on the comment" do
      create(:comment_like, comment: comment, user: liker)

      expect do
        delete user_unlike_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change { comment.reload.likes_count }.by(-1)
    end

    it "destroys associated notification when unliking" do
      create(:comment_like, comment: comment, user: liker)

      expect do
        delete user_unlike_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change { Notification.where(action: :comment_liked).count }.by(-1)
    end

    it "handles unliking when no like exists gracefully" do
      delete user_unlike_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream

      expect(response).to have_http_status(:ok)
    end

  end

  describe "authentication" do
    it "redirects to login when liking unauthenticated" do
      post user_like_comment_path(slug: author, uuid: article, id: comment)
      expect(response).to redirect_to(login_path)
    end

    it "redirects to login when unliking unauthenticated" do
      create(:comment_like, comment: comment, user: liker)

      delete user_unlike_comment_path(slug: author, uuid: article, id: comment)
      expect(response).to redirect_to(login_path)
    end
  end
end
