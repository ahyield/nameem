require "rails_helper"

RSpec.describe Settings::ProfileController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  describe "GET #edit" do
    context "when user is authorized to edit" do
      before do
        sign_in user
      end

      it "assigns the current user to @user" do
        get :edit
        expect(assigns(:user)).to eq(user)
      end

      it "returns a successful response" do
        get :edit
        expect(response).to be_successful
      end
    end

    context "when user is not authorized to edit" do
      before do
        sign_in another_user
        allow(controller).to receive(:authorize).with(another_user, :edit?).and_raise(Pundit::NotAuthorizedError)
      end

      it "raises a Pundit::NotAuthorizedError" do
        expect do
          get :edit
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PATCH #update" do
    context "when user is authorized to update" do
      before do
        sign_in user
        allow(controller).to receive(:authorize).with(user, :update?).and_return(true)
      end

      context "with valid parameters" do
        it "updates the user and redirects to settings page" do
          patch :update, params: { user: { name: "New Name", bio: "New bio" } }
          user.reload
          expect(user.name).to eq("New Name")
          expect(user.bio).to eq("New bio")
          expect(response).to redirect_to(settings_user_settings_path)
          expect(flash[:notice]).to eq("تم حفظ البيانات بنجاح")
        end
      end

      context "with invalid parameters" do
        it "renders the edit template with an error" do
          error = "لا يمكن أن يكون محتوى الاسم فارغاً و محتوى الاسم أقصر من اللّازم (الحد الأدنى هو 3 حروف)"

          allow(user).to receive_messages(update: false)

          # Mock the errors object directly
          errors = ActiveModel::Errors.new(user)
          errors.add(:base, "Error message")
          allow(user).to receive(:errors).and_return(errors)

          patch :update, params: { user: { name: "" } }

          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_content)
          expect(flash.now[:error]).to eq(error)
        end
      end
    end

    context "when user is not authorized to update" do
      before do
        sign_in user
        allow(controller).to receive(:authorize).with(user, :update?).and_raise(Pundit::NotAuthorizedError)
      end

      it "raises a Pundit::NotAuthorizedError" do
        expect do
          patch :update, params: { user: { name: "New Name" } }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
