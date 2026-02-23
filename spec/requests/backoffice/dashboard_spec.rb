require "rails_helper"

RSpec.describe "Backoffice::Dashboard", type: :request do
  describe "GET /backoffice/dashboard" do
    context "when not authenticated" do
      it "redirects to login" do
        get backoffice_dashboard_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated as regular user" do
      let(:user) { create(:user) }

      before { authenticate_user(user) }

      it "redirects to root" do
        get backoffice_dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when authenticated as editor" do
      let(:editor) { create(:editor) }

      before { authenticate_user(editor) }

      it "returns success" do
        get backoffice_dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as admin" do
      let(:admin) { create(:admin) }

      before { authenticate_user(admin) }

      it "returns success" do
        get backoffice_dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /backoffice" do
    let(:admin) { create(:admin) }

    before { authenticate_user(admin) }

    it "returns success" do
      get backoffice_root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
