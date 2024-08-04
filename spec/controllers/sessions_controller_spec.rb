require "rails_helper"

RSpec.describe SessionsController do
  let(:user) { create(:user, confirmed: true) }
  let(:unconfirmed_user) { create(:user, confirmed: false) }
  let(:token) { "stubbed_token" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(User).to receive(:generate_token_for).with(:magic_login).and_return(token)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "GET #new" do
    context "when user is signed in" do
      before do
        sign_in user
      end

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
      it "sends a magic login link email and redirects to root path" do
        mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(MagicLoginLinkMailer).to receive(:with)
          .and_return(instance_double(MagicLoginLinkMailer, magic_login_link: mailer_double))

        post :create, params: { login: { email: user.email } }

        expect(MagicLoginLinkMailer).to have_received(:with).once.with(hash_including(user:, token:))
        expect(mailer_double).to have_received(:deliver_later).once

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("من فضلك تحقق من بريدك الإليكتروني.")
      end
    end

    context "when the user is not confirmed or does not exist" do
      it "renders the new template with an error" do
        post :create, params: { login: { email: unconfirmed_user.email } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to eq("عفوًا هذا الحساب غير موجود")
      end

      it "renders the new template with an error for non-existing user" do
        post :create, params: { login: { email: "nonexisting@example.com" } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to eq("عفوًا هذا الحساب غير موجود")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in user
    end

    it "logs out the user and redirects to root path" do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
