class RegistrationsController < ApplicationController
  include Authentication::UnauthenticatedAccess
  include Authentication::ViaMagicLink

  before_action :redirect_authenticated_user, only: [:new]

  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    flash[:error] = "عدد المحاولات كبير، يرجى المحاولة لاحقًا"
    redirect_to signup_path
  }

  def new; end

  def create
    @user = User.find_by(email: sign_up_params[:email])

    if @user&.confirmed?
      flash.now[:error] = "هذا المستخدم موجود بالفعل"
      render :new, status: :unprocessable_content
    elsif valid_captcha?(model: @user)
      user = User.find_or_create_by(email: sign_up_params[:email])
      magic_link = user.send_magic_link(purpose: :sign_up)
      redirect_to_magic_link_verification(magic_link)
    else
      flash.now[:error] = "فشل التحقق من الكابتشا"
      render :new, status: :unprocessable_content
    end
  end

  private

  def sign_up_params
    params[:sign_up]
  end
end
