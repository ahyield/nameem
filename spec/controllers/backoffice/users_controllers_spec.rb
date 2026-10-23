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
      expect(assigns(:users).map(&:id)).to eq(User.confirmed.order(created_at: :asc).map(&:id))
    end

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "updates the user and redirects" do
        patch :update, params: { slug: user.slug, user: { featured: true } }
        user.reload
        expect(user.featured).to be_truthy
        expect(response).to redirect_to(backoffice_user_path(user))
        expect(flash[:notice]).to eq("تم تحديث البيانات بنجاح")
      end
    end

    context "with invalid parameters" do
      it "redirects back to the user with an error" do
        patch :update, params: { slug: user.slug, user: { featured: nil } }

        expect(response).to redirect_to(backoffice_user_path(user))
        expect(flash[:error]).not_to be_nil
      end
    end
  end
end
