require "rails_helper"

RSpec.describe Comment do
  describe "associations" do
    it "belongs to an article" do
      comment = create(:comment)
      expect(comment.article).to be_a(Article)
    end

    it "belongs to a user" do
      comment = create(:comment)
      expect(comment.user).to be_a(User)
    end

    it "has rich text body" do
      comment = create(:comment, body: "تعليق جميل")
      expect(comment.body.to_plain_text).to eq("تعليق جميل")
    end

    it "optionally belongs to a parent comment" do
      parent = create(:comment)
      reply = create(:comment, parent: parent, article: parent.article)
      expect(reply.parent).to eq(parent)
    end

    it "allows nil parent (top-level comment)" do
      comment = create(:comment)
      expect(comment.parent).to be_nil
    end

    it "optionally belongs to a mentioned_user" do
      mentioned = create(:user)
      parent = create(:comment)
      reply = create(:comment, parent: parent, article: parent.article, mentioned_user: mentioned)
      expect(reply.mentioned_user).to eq(mentioned)
    end

    it "has many replies" do
      parent = create(:comment)
      reply1 = create(:comment, parent: parent, article: parent.article)
      reply2 = create(:comment, parent: parent, article: parent.article)
      expect(parent.replies).to contain_exactly(reply1, reply2)
    end

    it "has many comment_likes" do
      comment = create(:comment)
      like = create(:comment_like, comment: comment)
      expect(comment.comment_likes).to include(like)
    end

    it "has many notifications" do
      comment = create(:comment)
      expect(comment).to respond_to(:notifications)
    end
  end

  describe "validations" do
    it "is invalid without a body" do
      comment = build(:comment, body: nil)
      expect(comment).not_to be_valid
    end

    it "is valid with a body" do
      comment = build(:comment, body: "تعليق")
      expect(comment).to be_valid
    end
  end

  describe "scopes" do
    it ".top_level returns only comments without a parent" do
      article = create(:article)
      top_level = create(:comment, article: article)
      create(:comment, article: article, parent: top_level)

      expect(article.comments.top_level).to contain_exactly(top_level)
    end

    it ".top_level excludes all replies" do
      article = create(:article)
      parent1 = create(:comment, article: article)
      parent2 = create(:comment, article: article)
      create(:comment, article: article, parent: parent1)
      create(:comment, article: article, parent: parent2)

      expect(article.comments.top_level).to contain_exactly(parent1, parent2)
    end
  end

  describe "counter caches" do
    it "increments comments_count on article when created" do
      article = create(:article)
      expect do
        create(:comment, article: article)
      end.to change { article.reload.comments_count }.by(1)
    end

    it "decrements comments_count on article when destroyed" do
      article = create(:article)
      comment = create(:comment, article: article)
      expect do
        comment.destroy
      end.to change { article.reload.comments_count }.by(-1)
    end

    it "increments replies_count on parent when reply created" do
      parent = create(:comment)
      expect do
        create(:comment, parent: parent, article: parent.article)
      end.to change { parent.reload.replies_count }.by(1)
    end

    it "decrements replies_count on parent when reply destroyed" do
      parent = create(:comment)
      reply = create(:comment, parent: parent, article: parent.article)
      expect do
        reply.destroy
      end.to change { parent.reload.replies_count }.by(-1)
    end

    it "increments likes_count on comment when liked" do
      comment = create(:comment)
      expect do
        create(:comment_like, comment: comment)
      end.to change { comment.reload.likes_count }.by(1)
    end

    it "replies also increment article comments_count" do
      article = create(:article)
      parent = create(:comment, article: article)
      expect do
        create(:comment, article: article, parent: parent)
      end.to change { article.reload.comments_count }.by(1)
    end
  end

  describe "threading" do
    let(:article) { create(:article) }

    it "a reply knows its parent" do
      parent = create(:comment, article: article)
      reply = create(:comment, article: article, parent: parent)
      expect(reply.parent).to eq(parent)
      expect(reply.parent_id).to eq(parent.id)
    end

    it "a top-level comment has no parent_id" do
      comment = create(:comment, article: article)
      expect(comment.parent_id).to be_nil
    end

    it "replies are accessible from the parent" do
      parent = create(:comment, article: article)
      r1 = create(:comment, article: article, parent: parent)
      r2 = create(:comment, article: article, parent: parent)
      expect(parent.replies.order(:id)).to eq([r1, r2])
    end

    it "a collapsed reply-to-reply stores mentioned_user" do
      parent = create(:comment, article: article)
      reply_user = create(:user)
      reply = create(:comment, article: article, parent: parent, user: reply_user)
      collapsed = create(:comment, article: article, parent: parent, mentioned_user: reply_user)
      expect(collapsed.mentioned_user).to eq(reply_user)
      expect(collapsed.parent).to eq(parent)
    end
  end

  describe "notifications" do
    context "top-level comment" do
      it "creates a :commented notification to article author" do
        article = create(:article)
        commenter = create(:user)

        expect do
          create(:comment, article: article, user: commenter, body: "تعليق")
        end.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.action).to eq("commented")
        expect(notification.recipient).to eq(article.user)
        expect(notification.actor).to eq(commenter)
        expect(notification.notifiable_type).to eq("Comment")
      end

      it "does not create a notification on self-comment" do
        article = create(:article)

        expect do
          create(:comment, article: article, user: article.user, body: "تعليق")
        end.not_to change(Notification, :count)
      end
    end

    context "reply to top-level" do
      it "creates a :replied notification to parent comment author" do
        parent = create(:comment)
        replier = create(:user)

        expect do
          create(:comment, parent: parent, article: parent.article, user: replier, body: "رد")
        end.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.action).to eq("replied")
        expect(notification.recipient).to eq(parent.user)
        expect(notification.actor).to eq(replier)
      end

      it "does not create a notification when replying to own comment" do
        parent = create(:comment)

        expect do
          create(:comment, parent: parent, article: parent.article, user: parent.user, body: "رد")
        end.not_to change(Notification, :count)
      end

      it "notifies the parent author, not the article author" do
        article = create(:article)
        commenter = create(:user)
        parent = create(:comment, article: article, user: commenter)
        replier = create(:user)

        create(:comment, parent: parent, article: article, user: replier, body: "رد")

        notification = Notification.where(action: :replied).last
        expect(notification.recipient).to eq(commenter)
        expect(notification.recipient).not_to eq(article.user)
      end
    end

    context "reply with mentioned_user (collapsed reply-to-reply)" do
      it "creates a :replied notification to mentioned_user" do
        parent = create(:comment)
        mentioned = create(:user)
        replier = create(:user)

        expect do
          create(:comment, parent: parent, article: parent.article,
                           user: replier, mentioned_user: mentioned, body: "رد على رد")
        end.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.action).to eq("replied")
        expect(notification.recipient).to eq(mentioned)
      end

      it "does not notify when mentioned_user is self" do
        parent = create(:comment)
        replier = create(:user)

        expect do
          create(:comment, parent: parent, article: parent.article,
                           user: replier, mentioned_user: replier, body: "رد")
        end.not_to change(Notification, :count)
      end

      it "notifies mentioned_user, not the parent author" do
        parent = create(:comment)
        mentioned = create(:user)
        replier = create(:user)

        create(:comment, parent: parent, article: parent.article,
                         user: replier, mentioned_user: mentioned, body: "رد")

        notification = Notification.where(action: :replied).last
        expect(notification.recipient).to eq(mentioned)
        expect(notification.recipient).not_to eq(parent.user)
      end
    end
  end

  describe "dependent destroy" do
    it "destroys replies when parent is destroyed" do
      parent = create(:comment)
      create(:comment, parent: parent, article: parent.article)
      create(:comment, parent: parent, article: parent.article)

      expect { parent.destroy }.to change(Comment, :count).by(-3)
    end

    it "destroys comment_likes when comment is destroyed" do
      comment = create(:comment)
      create(:comment_like, comment: comment)
      create(:comment_like, comment: comment)

      expect { comment.destroy }.to change(CommentLike, :count).by(-2)
    end

    it "destroys notifications when comment is destroyed" do
      article = create(:article)
      commenter = create(:user)
      comment = create(:comment, article: article, user: commenter)

      expect(Notification.where(notifiable: comment).count).to eq(1)
      comment.destroy
      expect(Notification.where(notifiable: comment).count).to eq(0)
    end

    it "cascade-destroys reply likes when parent is destroyed" do
      parent = create(:comment)
      reply = create(:comment, parent: parent, article: parent.article)
      create(:comment_like, comment: reply)

      expect { parent.destroy }.to change(CommentLike, :count).by(-1)
    end
  end
end
