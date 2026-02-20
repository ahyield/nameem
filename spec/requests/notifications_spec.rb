require "rails_helper"

RSpec.describe "Notifications" do
  let(:user) { create(:user) }

  describe "GET /notifications" do
    context "when authenticated" do
      before { authenticate_user(user) }

      it "returns success" do
        get "/notifications"
        expect(response).to have_http_status(:success)
      end

      it "shows the user's notifications" do
        notification = create(:notification, recipient: user)
        get "/notifications"
        expect(response.body).to include(notification.actor.name)
      end

      it "does not show other users' notifications" do
        other_user = create(:user)
        create(:notification, recipient: other_user)

        get "/notifications"
        expect(response.body).to include("لا توجد إشعارات")
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get "/notifications"
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /notifications/:id/mark_read" do
    before { authenticate_user(user) }

    it "marks the notification as read" do
      notification = create(:notification, recipient: user)

      post "/notifications/#{notification.id}/mark_read"

      expect(notification.reload.read_at).to be_present
    end

    it "returns 404 for other users' notifications" do
      other_user = create(:user)
      notification = create(:notification, recipient: other_user)

      post "/notifications/#{notification.id}/mark_read"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /notifications/mark_all_read" do
    before { authenticate_user(user) }

    it "marks all unread notifications as read" do
      create(:notification, recipient: user)
      create(:notification, recipient: user)

      post "/notifications/mark_all_read"

      expect(user.notifications.unread.count).to eq(0)
    end

    it "redirects to notifications index" do
      post "/notifications/mark_all_read"
      expect(response).to redirect_to(notifications_path)
    end
  end
end
