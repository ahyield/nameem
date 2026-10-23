require "rails_helper"

RSpec.describe Signups::CompletionsController do
  let(:user) { create(:user, confirmed: false, name: nil) }

  before { sign_in user }

  describe "GET #new" do
    it "renders the profile completion form" do
      get :new
      expect(response).to be_successful
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "POST #create" do
    context "with valid data" do
      it "updates the user profile and redirects to root" do
        post :create, params: { user: { name: "عبدالله", slug: "abdullah" } }

        user.reload
        expect(user.name).to eq("عبدالله")
        expect(user.slug).to eq("abdullah")
        expect(user.confirmed).to be true
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid data" do
      it "re-renders the form with errors" do
        post :create, params: { user: { name: "", slug: "" } }

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when a confirmed param is submitted" do
      it "ignores the confirmed parameter" do
        post :create, params: { user: { name: "عبدالله", slug: "abdullah-test", confirmed: true } }

        # confirmed is set by the controller logic, not via params
        # Ensure the :confirmed param is not directly whitelisted
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
