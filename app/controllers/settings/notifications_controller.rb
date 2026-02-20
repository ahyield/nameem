module Settings
  class NotificationsController < ApplicationController
    def edit
      @user = current_user
      authorize @user, :edit?
    end

    def update
      @user = current_user
      authorize @user, :update?

      if @user.update(user_params)
        flash[:notice] = "تم حفظ الإعدادات بنجاح"
        redirect_to settings_notifications_path
      else
        flash.now[:error] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_content
      end
    end

    private

    def user_params
      params.expect(user: [:email_notifications])
    end
  end
end
