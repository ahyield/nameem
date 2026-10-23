module Settings
  class SecurityController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      return head :ok if @user.email == user_params[:email] && @user.confirmed?

      user_by_email = User.find_by(email: user_params[:email])

      if user_by_email&.confirmed?
        flash.now[:error] = "هذا المستخدم موجود بالفعل"
        render :edit, status: :unprocessable_content
      else
        change_email(user_params[:email])

        flash[:notice] = "تم إرسال رمز التأكيد إلى بريدك الإلكتروني"
        redirect_to settings_security_path
      end
    end

    private

    # The new address must be confirmed with a code; the old one hears about the change
    def change_email(new_email)
      old_email = @user.email
      @user.update(confirmed: false)
      @user.update(email: new_email)
      AccountMailer.email_changed(@user, old_email:).deliver_later unless old_email == @user.email
      @user.send_magic_link(purpose: :confirm_email)
    end

    def user_params
      params.expect(user: [:email])
    end
  end
end
