class CallbacksController < ApplicationController
  def new
    @email = params[:email]
    @token = params[:token]

    @user = User.find_by_token_for(:magic_login,  @token)
    if !@user && !@user&.confirmed?
      flash[:error] = "لم نجد مستخدم"
      redirect_to root_path
    end
  end

  def create
    @user = User.find_by(email: required_params[:email])
    @user.attributes = user_params
    @user.confirmed = true unless @user.name.nil?
    if @user.save
      authenticate_user_after_sign_up(@user)
    else
      render :new, notice: "الإسم مطلوب"
    end
  end

  def login
    @user = User.find_by_token_for(:magic_login,  params[:token])
    if @user && @user.confirmed
      authenticate_user_after_sign_up(@user)
    else
      flash[:error] = "عفوًا حدث خطأ"
      redirect_to root_path
    end
  end

  private

  def user_params
    user_params = params[:user]
    user_params ? user_params.permit(:email, :name, :confirmed) : {}
  end

  def required_params
    params.require(:user)
  end
end
