class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_signed_in_users, only: [:new]

  def new; end

  def create
    @user = User.find_by(email: sign_up_params[:email])

    if valid_captcha?(model: @user)
      if @user&.confirmed?
        flash.now[:error] = "هذا المستخدم موجود بالفعل"
        render :new, status: :unprocessable_entity
      else
        user = User.find_or_create_by(email: sign_up_params[:email])

        MagicSignUpLinkMailer.with(email: sign_up_params[:email],
                                   token: user.generate_token_for(:magic_login)).magic_sign_up_link.deliver_later
        redirect_to root_path, notice: "من فضلك راجع بريدك الإليكتروني"
      end
    else
      flash.now[:error] = "عفوًا فشل التحقق من الكابتشا"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_signed_in_users
    return unless user_signed_in?

    redirect_to root_path
  end

  def sign_up_params
    params[:sign_up]
  end
end
