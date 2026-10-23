require "rails_helper"

RSpec.describe "Backoffice::Users", type: :request do
  let(:admin) { create(:admin) }
  let(:editor) { create(:editor) }

  describe "GET /backoffice/users" do
    before { authenticate_user(editor) }

    it "returns success" do
      get backoffice_users_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by confirmed" do
      get backoffice_users_path(filter: "confirmed")
      expect(response).to have_http_status(:ok)
    end

    it "filters by unconfirmed" do
      get backoffice_users_path(filter: "unconfirmed")
      expect(response).to have_http_status(:ok)
    end

    it "filters by featured" do
      get backoffice_users_path(filter: "featured")
      expect(response).to have_http_status(:ok)
    end

    it "searches by name" do
      get backoffice_users_path(q: "test")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /backoffice/users/:slug" do
    let(:user) { create(:user) }

    before { authenticate_user(editor) }

    it "returns success" do
      get backoffice_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT /backoffice/users/:slug" do
    let(:user) { create(:user) }

    context "as editor" do
      before { authenticate_user(editor) }

      it "updates featured and picked" do
        put backoffice_user_path(user), params: { user: { featured: true, picked: true } }
        expect(response).to redirect_to(backoffice_user_path(user))
        user.reload
        expect(user.featured).to be true
        expect(user.picked).to be true
      end

      it "cannot set admin role" do
        put backoffice_user_path(user), params: { user: { admin: true } }
        user.reload
        expect(user.admin).to be false
      end
    end

    context "as admin" do
      before { authenticate_user(admin) }

      it "can set admin role" do
        put backoffice_user_path(user), params: { user: { admin: true } }
        user.reload
        expect(user.admin).to be true
      end

      it "can set editor role" do
        put backoffice_user_path(user), params: { user: { editor: true } }
        user.reload
        expect(user.editor).to be true
      end
    end
  end

  describe "DELETE /backoffice/users/:slug" do
    let!(:user) { create(:user) }

    context "as editor" do
      before { authenticate_user(editor) }

      it "redirects (admin only)" do
        delete backoffice_user_path(user)
        expect(response).to redirect_to(backoffice_root_path)
        expect(User.exists?(user.id)).to be true
      end
    end

    context "as admin" do
      before { authenticate_user(admin) }

      it "deletes the user" do
        delete backoffice_user_path(user)
        expect(response).to redirect_to(backoffice_users_path)
        expect(User.exists?(user.id)).to be false
      end
    end
  end

  describe "POST /backoffice/users/:slug/toggle_role" do
    let(:user) { create(:user) }

    context "as editor" do
      before { authenticate_user(editor) }

      it "toggles featured" do
        post toggle_role_backoffice_user_path(user), params: { role: "featured" }
        user.reload
        expect(user.featured).to be true
      end

      it "toggles confirmed" do
        user.update!(confirmed: false)
        post toggle_role_backoffice_user_path(user), params: { role: "confirmed" }
        user.reload
        expect(user.confirmed).to be true
      end

      it "cannot toggle admin" do
        post toggle_role_backoffice_user_path(user), params: { role: "admin" }
        expect(response).to redirect_to(backoffice_user_path(user))
        user.reload
        expect(user.admin).to be false
      end
    end

    context "as admin" do
      before { authenticate_user(admin) }

      it "can toggle admin" do
        post toggle_role_backoffice_user_path(user), params: { role: "admin" }
        user.reload
        expect(user.admin).to be true
      end

      it "can toggle editor" do
        post toggle_role_backoffice_user_path(user), params: { role: "editor" }
        user.reload
        expect(user.editor).to be true
      end
    end
  end
end
