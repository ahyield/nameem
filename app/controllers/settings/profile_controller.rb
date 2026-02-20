module Settings
  class ProfileController < ApplicationController
    def edit
      @user = current_user
      authorize @user, :edit?
    end

    def update
      @user = current_user
      authorize @user, :update?

      if @user.update(user_params)
        flash[:notice] = "تم حفظ البيانات بنجاح"
        redirect_to settings_user_settings_path
      else
        flash.now[:error] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.expect(user: %i[name avatar slug bio website_url twitter_handle instagram_handle facebook_handle])
    end
  end
end
