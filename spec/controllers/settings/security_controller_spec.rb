require "rails_helper"

RSpec.describe Settings::SecurityController do
  let(:user) { create(:user) }
  let(:unconfirmed_user) { create(:user, :unconfirmed) }
  let(:other_user) { create(:user, email: "other@example.com") }
  let(:token) { "stubbed_token" }

  before do
    sign_in user
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(User).to receive(:generate_token_for).with(:magic_login).and_return(token)
    # rubocop:enable RSpec/AnyInstance
  end

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
      it "sends a confirmation email, updates the user's email, and redirects" do
        mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ConfirmEmailMailer).to receive(:with).and_return(instance_double(ConfirmEmailMailer, confirm_email: mailer_double))

        patch :update, params: { user: { email: "newemail@example.com" } }

        expect(ConfirmEmailMailer).to have_received(:with).once.with(email: "newemail@example.com", token:)
        expect(mailer_double).to have_received(:deliver_later).once

        user.reload
        expect(user.email).to eq("newemail@example.com")
        expect(user.confirmed).to be_nil

        expect(response).to redirect_to(settings_security_path)
        expect(flash[:notice]).to eq("تم إرسال رابط التأكيد إلى بريدك الإلكتروني")
      end
    end
  end
end
