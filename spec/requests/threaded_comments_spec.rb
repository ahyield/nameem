require "rails_helper"

RSpec.describe "Threaded Comments" do
  let(:author) { create(:user) }
  let(:article) { create(:article, :published, user: author) }
  let(:commenter) { create(:user) }

  describe "POST /:slug/:uuid/comments (top-level)" do
    before { authenticate_user(commenter) }

    it "creates a top-level comment" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "تعليق جديد" } },
             as: :turbo_stream
      end.to change(Comment, :count).by(1)

      comment = Comment.last
      expect(comment.parent_id).to be_nil
      expect(comment.mentioned_user).to be_nil
    end

    it "increments article comments_count" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "تعليق" } },
             as: :turbo_stream
      end.to change { article.reload.comments_count }.by(1)
    end

    it "creates a :commented notification to the article author" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "تعليق" } },
             as: :turbo_stream
      end.to change { Notification.where(action: :commented).count }.by(1)

      notification = Notification.where(action: :commented).last
      expect(notification.recipient).to eq(author)
      expect(notification.actor).to eq(commenter)
    end

    it "does not create a notification when commenting on own article" do
      authenticate_user(author)

      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "تعليقي" } },
             as: :turbo_stream
      end.not_to change(Notification, :count)
    end

    it "rejects empty body" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "" } },
             as: :turbo_stream
      end.not_to change(Comment, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /:slug/:uuid/comments with parent_id (reply)" do
    before { authenticate_user(commenter) }

    let!(:parent) { create(:comment, article: article, user: author) }

    it "creates a reply to a top-level comment" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد على التعليق", parent_id: parent.id } },
             as: :turbo_stream
      end.to change(Comment, :count).by(1)

      reply = Comment.last
      expect(reply.parent).to eq(parent)
      expect(reply.mentioned_user).to be_nil
      expect(response).to have_http_status(:ok)
    end

    it "increments replies_count on parent" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد", parent_id: parent.id } },
             as: :turbo_stream
      end.to change { parent.reload.replies_count }.by(1)
    end

    it "creates a :replied notification to parent comment author" do
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد", parent_id: parent.id } },
             as: :turbo_stream
      end.to change { Notification.where(action: :replied).count }.by(1)

      notification = Notification.where(action: :replied).last
      expect(notification.recipient).to eq(author)
      expect(notification.actor).to eq(commenter)
    end

    it "does not create a :replied notification when replying to own comment" do
      own_comment = create(:comment, article: article, user: commenter)

      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد على نفسي", parent_id: own_comment.id } },
             as: :turbo_stream
      end.not_to change { Notification.where(action: :replied).count }
    end
  end

  describe "POST /:slug/:uuid/comments with reply-to-reply (collapse)" do
    before { authenticate_user(commenter) }

    it "collapses reply-to-reply to grandparent and sets mentioned_user" do
      grandparent = create(:comment, article: article, user: author)
      parent_reply = create(:comment, article: article, user: commenter, parent: grandparent)

      third_user = create(:user)
      authenticate_user(third_user)

      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد على الرد", parent_id: parent_reply.id } },
             as: :turbo_stream
      end.to change(Comment, :count).by(1)

      collapsed = Comment.last
      expect(collapsed.parent).to eq(grandparent)
      expect(collapsed.mentioned_user).to eq(commenter)
    end

    it "creates a :replied notification to mentioned_user on collapsed reply" do
      grandparent = create(:comment, article: article, user: author)
      reply_user = create(:user)
      parent_reply = create(:comment, article: article, user: reply_user, parent: grandparent)

      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد على الرد", parent_id: parent_reply.id } },
             as: :turbo_stream
      end.to change { Notification.where(action: :replied).count }.by(1)

      notification = Notification.where(action: :replied).last
      expect(notification.recipient).to eq(reply_user)
    end

    it "does not notify when collapsed mentioned_user is self" do
      grandparent = create(:comment, article: article, user: author)
      parent_reply = create(:comment, article: article, user: commenter, parent: grandparent)

      # commenter replies to their own reply — no notification
      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد على ردي", parent_id: parent_reply.id } },
             as: :turbo_stream
      end.not_to change { Notification.where(action: :replied).count }
    end

    it "increments replies_count on grandparent (not on the reply)" do
      grandparent = create(:comment, article: article, user: author)
      parent_reply = create(:comment, article: article, user: commenter, parent: grandparent)

      third_user = create(:user)
      authenticate_user(third_user)

      expect do
        post user_article_comments_path(slug: author, uuid: article),
             params: { comment: { body: "رد", parent_id: parent_reply.id } },
             as: :turbo_stream
      end.to change { grandparent.reload.replies_count }.by(1)

      expect(parent_reply.reload.replies_count).to eq(0)
    end
  end

  describe "DELETE /:slug/:uuid/comments/:id" do
    before { authenticate_user(commenter) }

    it "destroys own comment" do
      comment = create(:comment, article: article, user: commenter)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change(Comment, :count).by(-1)
    end

    it "destroys a reply" do
      parent = create(:comment, article: article, user: author)
      reply = create(:comment, article: article, user: commenter, parent: parent)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: reply),
               as: :turbo_stream
      end.to change(Comment, :count).by(-1)
    end

    it "cascade-destroys replies when parent is deleted" do
      parent = create(:comment, article: article, user: commenter)
      create(:comment, article: article, parent: parent)
      create(:comment, article: article, parent: parent)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: parent),
               as: :turbo_stream
      end.to change(Comment, :count).by(-3)
    end

    it "allows admin to delete any comment" do
      admin = create(:user, :admin)
      authenticate_user(admin)
      comment = create(:comment, article: article, user: commenter)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change(Comment, :count).by(-1)
    end

    it "forbids deleting another user's comment" do
      other_user = create(:user)
      comment = create(:comment, article: article, user: other_user)

      delete user_article_comment_path(slug: author, uuid: article, id: comment),
             as: :turbo_stream

      expect(response).to have_http_status(:forbidden)
    end

    it "decrements article comments_count" do
      comment = create(:comment, article: article, user: commenter)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: comment),
               as: :turbo_stream
      end.to change { article.reload.comments_count }.by(-1)
    end

    it "decrements parent replies_count when reply is deleted" do
      parent = create(:comment, article: article, user: author)
      reply = create(:comment, article: article, user: commenter, parent: parent)

      expect do
        delete user_article_comment_path(slug: author, uuid: article, id: reply),
               as: :turbo_stream
      end.to change { parent.reload.replies_count }.by(-1)
    end
  end

  describe "authentication", :no_auth do
    it "redirects to login when creating a comment unauthenticated" do
      post user_article_comments_path(slug: author, uuid: article),
           params: { comment: { body: "test" } }

      expect(response).to redirect_to(login_path)
    end

    it "redirects to login when deleting a comment unauthenticated" do
      comment = create(:comment, article: article, user: commenter)

      delete user_article_comment_path(slug: author, uuid: article, id: comment)

      expect(response).to redirect_to(login_path)
    end
  end
end
