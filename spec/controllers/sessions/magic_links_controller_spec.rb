require "rails_helper"

RSpec.describe Sessions::MagicLinksController do
  let(:user) { create(:user, confirmed: true) }

  describe "GET #show" do
    context "when pending_authentication cookie exists" do
      before do
        cookies.signed[:pending_authentication_token] = user.email
      end

      it "renders the code entry form" do
        get :show
        expect(response).to be_successful
      end
    end

    context "when no pending_authentication cookie" do
      it "redirects to login" do
        get :show
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST #create" do
    context "with valid sign_in code" do
      let!(:magic_link) { create(:magic_link, user: user, purpose: :sign_in) }

      before do
        cookies.signed[:pending_authentication_token] = user.email
      end

      it "creates a session, sets cookie, and redirects to root" do
        post :create, params: { code: magic_link.code }

        expect(Session.count).to eq(1)
        expect(cookies[:session_token]).to be_present
        expect(response).to redirect_to(root_path)
      end
    end

    context "with valid sign_up code" do
      let(:unconfirmed_user) { create(:user, confirmed: false) }
      let!(:magic_link) { create(:magic_link, user: unconfirmed_user, purpose: :sign_up) }

      before do
        cookies.signed[:pending_authentication_token] = unconfirmed_user.email
      end

      it "creates a session and redirects to signup completion" do
        post :create, params: { code: magic_link.code }

        expect(Session.count).to eq(1)
        expect(response).to redirect_to(new_signups_completion_path)
      end
    end

    context "with valid confirm_email code" do
      let!(:magic_link) { create(:magic_link, user: user, purpose: :confirm_email) }

      before do
        user.update!(confirmed: false)
        cookies.signed[:pending_authentication_token] = user.email
      end

      it "confirms the user, creates a session, and redirects to root" do
        post :create, params: { code: magic_link.code }

        expect(user.reload.confirmed).to be true
        expect(Session.count).to eq(1)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("تم تأكيد بريدك الإلكتروني")
      end
    end

    context "with expired code" do
      let!(:magic_link) { create(:magic_link, :expired, user: user) }

      before do
        cookies.signed[:pending_authentication_token] = user.email
      end

      it "re-renders the form with error" do
        post :create, params: { code: magic_link.code }

        expect(response).to render_template(:show)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to be_present
      end
    end

    context "with wrong code" do
      before do
        cookies.signed[:pending_authentication_token] = user.email
      end

      it "re-renders the form with error" do
        post :create, params: { code: "ZZZZZZ" }

        expect(response).to render_template(:show)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to be_present
      end
    end

    context "with email mismatch" do
      let!(:magic_link) { create(:magic_link, user: user, purpose: :sign_in) }

      before do
        cookies.signed[:pending_authentication_token] = "other@example.com"
      end

      it "re-renders the form with error" do
        post :create, params: { code: magic_link.code }

        expect(response).to render_template(:show)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without pending_authentication cookie" do
      it "redirects to login" do
        post :create, params: { code: "ABC123" }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
