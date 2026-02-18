require "rails_helper"

RSpec.describe Settings::SecurityController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "other@example.com") }

  before { sign_in user }

  describe "GET #edit" do
    it "assigns the current user to @user" do
      get :edit
      expect(assigns(:user)).to eq(user)
    end

    it "returns a successful response" do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "when the email is unchanged and user is confirmed" do
      it "does nothing and returns a successful response" do
        patch :update, params: { user: { email: user.email } }
        expect(response).to have_http_status(:ok)
        expect(flash[:notice]).to be_nil
      end
    end

    context "when the new email belongs to a confirmed user" do
      it "renders the edit template with an error" do
        patch :update, params: { user: { email: other_user.email } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:error]).to eq("هذا المستخدم موجود بالفعل")
      end
    end

    context "when the new email does not belong to a confirmed user" do
      it "creates a confirm_email magic link, updates email, and redirects" do
        patch :update, params: { user: { email: "newemail@example.com" } }

        user.reload
        expect(user.email).to eq("newemail@example.com")
        expect(user.confirmed).to be false

        expect(user.magic_links.count).to eq(1)
        expect(user.magic_links.last).to be_confirm_email

        expect(response).to redirect_to(settings_security_path)
        expect(flash[:notice]).to eq("تم إرسال رمز التأكيد إلى بريدك الإلكتروني")
      end
    end
  end
end
