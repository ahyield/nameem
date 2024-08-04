require "rails_helper"

RSpec.describe CallbacksController do
  let(:user) { create(:user) }
  let(:unconfirmed_user) { create(:user, confirmed: false) }
  let(:token) { "valid_token" }
  let(:invalid_token) { "invalid_token" }

  before do
    allow(User).to receive(:find_by_token_for).and_return(nil)
    allow(User).to receive(:find_by_token_for).with(:magic_login, token).and_return(user)
  end

  describe "GET #new" do
    context "when the user is found by token" do
      it "does not redirect" do
        get :new, params: { token: }
        expect(response).not_to redirect_to(root_path)
      end
    end

    context "when the user is not found by token" do
      it "redirects to the root path" do
        get :new, params: { token: invalid_token }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("لم نجد مستخدم")
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      before do
        allow(User).to receive(:find_by).with(email: user.email).and_return(user)
      end

      it "updates the user and authenticates them" do
        post :create, params: { user: { email: user.email, name: "New Name", slug: "new-slug" } }
        expect(user.reload.confirmed).to be true
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      before do
        allow(User).to receive(:find_by).with(email: user.email).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "renders the new template with an error" do
        post :create, params: { user: { email: user.email, name: "", slug: "" } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #confirm_email" do
    context "when the user is found by token" do
      it "confirms the user and redirects with a notice" do
        get :confirm_email, params: { token: }
        expect(user.reload.confirmed).to be true
        expect(flash[:notice]).to eq("تم تأكيد بريدك الإلكتروني")
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user is not found by token" do
      it "redirects to the root path with an error" do
        get :confirm_email, params: { token: invalid_token }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("لم نجد مستخدم")
      end
    end
  end

  describe "GET #login" do
    context "when the user is confirmed" do
      it "authenticates the user and redirects" do
        get :login, params: { token: }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user is not confirmed" do
      before do
        allow(User).to receive(:find_by_token_for).with(:magic_login, token).and_return(unconfirmed_user)
      end

      it "redirects to the root path with an error" do
        get :login, params: { token: }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("عفوًا حدث خطأ")
      end
    end

    context "when the user is not found by token" do
      it "redirects to the root path with an error" do
        get :login, params: { token: invalid_token }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("عفوًا حدث خطأ")
      end
    end
  end
end
