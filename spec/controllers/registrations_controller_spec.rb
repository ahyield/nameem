require "rails_helper"

RSpec.describe RegistrationsController do
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
    context "when the user is already confirmed" do
      before do
        allow(controller).to receive(:valid_captcha?).and_return(true)
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
        allow(controller).to receive(:valid_captcha?).and_return(false)
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
        allow(controller).to receive(:valid_captcha?).and_return(true)
      end

      it "creates a magic link and redirects to code entry" do
        post :create, params: { sign_up: { email: unconfirmed_user.email } }

        expect(unconfirmed_user.magic_links.count).to eq(1)
        expect(unconfirmed_user.magic_links.last).to be_sign_up
        expect(response).to redirect_to(session_magic_link_path)
        expect(cookies[:pending_authentication_token]).to be_present
      end
    end

    context "with a new email" do
      before do
        allow(controller).to receive(:valid_captcha?).and_return(true)
      end

      it "creates user and magic link, redirects to code entry" do
        expect do
          post :create, params: { sign_up: { email: "newuser@example.com" } }
        end.to change(User, :count).by(1)

        user = User.find_by(email: "newuser@example.com")
        expect(user.magic_links.count).to eq(1)
        expect(response).to redirect_to(session_magic_link_path)
      end
    end
  end
end
