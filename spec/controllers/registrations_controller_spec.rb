require "rails_helper"

RSpec.describe RegistrationsController do
  let(:user) { create(:user, confirmed: true) }
  let(:unconfirmed_user) { create(:user, confirmed: false) }

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
    context "when the user is already confirmed" do
      before do
        allow(controller).to receive(:valid_captcha?).and_return(true) # Stub valid CAPTCHA
      end

      it "renders the new template with an error" do
        post :create, params: { sign_up: { email: user.email } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to eq("هذا المستخدم موجود بالفعل")
      end
    end

    context "when the CAPTCHA is invalid" do
      before do
        allow(controller).to receive(:valid_captcha?).and_return(false) # Stub invalid CAPTCHA
      end

      it "renders the new template with an error" do
        post :create, params: { sign_up: { email: unconfirmed_user.email } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to eq("فشل التحقق من الكابتشا")
      end
    end

    context "when the user is not confirmed and the CAPTCHA is valid" do
      before do
        allow(controller).to receive(:valid_captcha?).and_return(true) # Stub valid CAPTCHA
        allow(User).to receive(:find_or_create_by).and_return(unconfirmed_user)
        allow(unconfirmed_user).to receive(:generate_token_for).and_return("token")
      end

      it "sends a magic sign-up link email and redirects to root path" do
        mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(MagicSignUpLinkMailer).to receive(:with)
          .with(email: unconfirmed_user.email, token: "token")
          .and_return(instance_double(MagicSignUpLinkMailer, magic_sign_up_link: mailer_double))

        post :create, params: { sign_up: { email: unconfirmed_user.email } }

        expect(MagicSignUpLinkMailer).to have_received(:with).once.with(email: unconfirmed_user.email, token: "token")
        expect(mailer_double).to have_received(:deliver_later).once

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("من فضلك راجع بريدك الإليكتروني")
      end
    end
  end
end
