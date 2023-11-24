module Settings
  class ProfileController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update(user_params)
        flash[:notice] = "تم حفظ البيانات بنجاح"
        redirect_to settings_user_settings_path
      else
        flash.now[:error] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def user_params
      params.require(:user).permit(:name, :avatar, :email, :slug)
    end
  end
end
