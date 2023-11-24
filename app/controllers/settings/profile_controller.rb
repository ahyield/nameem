module Settings
  class ProfileController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user

      if email_changed?
        flash.now[:error] = "لا يمكن تغيير البريد الإلكتروني"
        render :edit, status: :unprocessable_entity
        return
      end

      if @user.update(user_params)
        flash[:notice] = "تم حفظ البيانات بنجاح"
        redirect_to settings_user_settings_path
      else
        flash.now[:error] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def email_changed?
      user_params[:email].present? && user_params[:email] != current_user.email
    end

    def user_params
      params.require(:user).permit(:name, :email, :avatar, :slug, :bio)
    end
  end
end
