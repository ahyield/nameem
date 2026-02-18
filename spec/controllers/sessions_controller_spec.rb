require "rails_helper"

RSpec.describe SessionsController do
  let(:user) { create(:user, confirmed: true) }
  let(:unconfirmed_user) { create(:user, confirmed: false) }

  describe "GET #new" do
    context "when user is signed in" do
      before { sign_in user }

      it "redirects to the root path" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is not signed in" do
      it "returns a successful response" do
        get :new
        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    context "when the user is confirmed" do
      it "creates a magic link, enqueues mailer, and redirects to code entry" do
        post :create, params: { login: { email: user.email } }

        expect(user.magic_links.count).to eq(1)
        expect(user.magic_links.last).to be_sign_in
        expect(response).to redirect_to(session_magic_link_path)
        expect(cookies[:pending_authentication_token]).to be_present
      end
    end

    context "when the user is not confirmed" do
      it "still redirects to code entry (anti-enumeration)" do
        post :create, params: { login: { email: unconfirmed_user.email } }

        expect(unconfirmed_user.magic_links.count).to eq(0)
        expect(response).to redirect_to(session_magic_link_path)
        expect(cookies[:pending_authentication_token]).to be_present
      end
    end

    context "when the user does not exist" do
      it "still redirects to code entry (anti-enumeration)" do
        post :create, params: { login: { email: "nonexisting@example.com" } }

        expect(MagicLink.count).to eq(0)
        expect(response).to redirect_to(session_magic_link_path)
        expect(cookies[:pending_authentication_token]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }

    it "destroys the session and redirects to root path" do
      expect { delete :destroy }.to change(Session, :count).by(-1)
      expect(cookies[:session_token]).to be_blank
      expect(response).to redirect_to(root_path)
    end
  end
end
