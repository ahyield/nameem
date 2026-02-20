require "rails_helper"

RSpec.describe "Follows" do
  let(:user) { create(:user) }

  describe "POST /:slug/follow (user follow)" do
    context "when authenticated" do
      before { authenticate_user(user) }

      it "creates a follow" do
        other_user = create(:user)

        expect {
          post user_follow_path(slug: other_user), as: :turbo_stream
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:success)
      end

      it "rejects self-follow" do
        expect {
          post user_follow_path(slug: user), as: :turbo_stream
        }.not_to change(Follow, :count)
      end

      it "does not create duplicate follows" do
        other_user = create(:user)
        create(:follow, follower: user, followable: other_user)

        expect {
          post user_follow_path(slug: other_user), as: :turbo_stream
        }.not_to change(Follow, :count)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        other_user = create(:user)
        post user_follow_path(slug: other_user)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE /:slug/follow (user unfollow)" do
    context "when authenticated" do
      before { authenticate_user(user) }

      it "destroys the follow" do
        other_user = create(:user)
        create(:follow, follower: user, followable: other_user)

        expect {
          delete user_unfollow_path(slug: other_user), as: :turbo_stream
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /topics/:slug/follow (tag follow)" do
    context "when authenticated" do
      before { authenticate_user(user) }

      it "creates a follow for a tag" do
        tag = create(:tag)

        expect {
          post follow_topic_path(tag), as: :turbo_stream
        }.to change(Follow, :count).by(1)

        expect(Follow.last.followable).to eq(tag)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        tag = create(:tag)
        post follow_topic_path(tag)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE /topics/:slug/unfollow (tag unfollow)" do
    context "when authenticated" do
      before { authenticate_user(user) }

      it "destroys the tag follow" do
        tag = create(:tag)
        create(:follow, follower: user, followable: tag)

        expect {
          delete unfollow_topic_path(tag), as: :turbo_stream
        }.to change(Follow, :count).by(-1)
      end
    end
  end

  describe "GET /:slug/followers" do
    it "shows the followers page" do
      other_user = create(:user)
      create(:follow, follower: user, followable: other_user)

      get user_followers_path(slug: other_user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.name)
    end
  end

  describe "GET /:slug/following" do
    it "shows the following page" do
      other_user = create(:user)
      create(:follow, follower: user, followable: other_user)

      get user_following_path(slug: user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(other_user.name)
    end
  end
end
