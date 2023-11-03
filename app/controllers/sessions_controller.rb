class SessionsController < ApplicationController
  before_action :redirect_signed_in_users, only: [:new]

  def new; end

  def create
    @user = User.find_by(email: login_params[:email])

    if @user && @user.confirmed?
      MagicLoginLinkMailer.with(user: @user,
                                token: @user.generate_token_for(:magic_login)).magic_login_link.deliver_later
      redirect_to root_path, notice: "من فضلك تحقق من بريدك الإليكتروني."
    else
      flash.now[:error] = "عفوًا هذا الحساب غير موجود"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user = nil
    reset_session
    redirect_to root_path
  end

  private

  def redirect_signed_in_users
    if user_signed_in?
      redirect_to root_path
    end
  end

  def login_params
    params[:login]
  end
end
