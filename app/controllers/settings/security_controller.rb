module Settings
  class SecurityController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      return if @user.email == user_params[:email] && @user.confirmed?

      user_by_email = User.find_by(email: user_params[:email])

      if user_by_email&.confirmed?
        flash.now[:error] = "هذا المستخدم موجود بالفعل"
        render :edit, status: :unprocessable_entity
      else
        ConfirmEmailMailer.with(email: user_params[:email],
                                token: @user.generate_token_for(:magic_login))
                          .confirm_email.deliver_later
        @user.update(confirmed: nil)
        @user.update(email: user_params[:email])

        flash[:notice] = "تم إرسال رابط التأكيد إلى بريدك الإلكتروني"
        redirect_to settings_security_path
      end
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
