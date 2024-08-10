require "rails_helper"

RSpec.describe Backoffice::UsersController do
  let(:admin_user) { create(:user, editor: true) }
  let(:regular_user) { create(:user, editor: false) }
  let(:user) { create(:user, slug: "test-user", confirmed: true) }

  before do
    sign_in admin_user
  end

  describe "GET #index" do
    it "assigns confirmed users to @users" do
      get :index
      expect(assigns(:users)).to eq(User.confirmed.order(created_at: :asc))
    end

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "assigns the requested user to @user" do
      get :edit, params: { slug: user.slug }
      expect(assigns(:user)).to eq(user)
    end

    it "returns a successful response" do
      get :edit, params: { slug: user.slug }
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "updates the user and redirects" do
        patch :update, params: { slug: user.slug, user: { featured: true } }
        user.reload
        expect(user.featured).to be_truthy
        expect(response).to redirect_to(backoffice_users_path)
        expect(flash[:notice]).to eq("تم تحديث البيانات بنجاح")
      end
    end

    context "with invalid parameters" do
      it "renders the edit template with an error" do
        patch :update, params: { slug: user.slug, user: { featured: nil } }

        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Validation error")
      end
    end
  end
end
