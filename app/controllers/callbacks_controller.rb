class CallbacksController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @email = params[:email]
    @token = params[:token]

    @user = User.find_by_token_for(:magic_login, @token)

    return unless @user.nil?

    flash.now[:error] = "لم نجد مستخدم"
    redirect_to root_path
  end

  def create
    @user = User.find_by(email: required_params[:email])
    @user.attributes = user_params
    @user.confirmed = true unless @user.name.blank? || @user.slug.blank?
    if @user.save
      authenticate_user_after_sign_up(@user)
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      @user.avatar = nil
      render :new, status: :unprocessable_entity
    end
  end

  def confirm_email
    @token = params[:token]
    @user = User.find_by_token_for(:magic_login, @token)
    if @user.nil?
      flash[:error] = "لم نجد مستخدم"
      redirect_to root_path
    else
      @user.update(confirmed: true)

      flash[:notice] = "تم تأكيد بريدك الإلكتروني"
      authenticate_user_after_sign_up(@user)
    end
  end

  def login
    @user = User.find_by_token_for(:magic_login, params[:token])

    if @user&.confirmed?
      authenticate_user_after_sign_up(@user)
    else
      flash[:error] = "عفوًا حدث خطأ"
      redirect_to root_path
    end
  end

  def facebook
    email = auth_hash.info["email"]
    @user = User.find_by(email: email)

    if @user&.confirmed?
      authenticate_user_after_sign_up(@user)
    else
      @user = User.create(email: email)
      render :new
    end
  end

  def failure
    flash[:error] = "عفوًا حدث خطأ"
    redirect_to root_path
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_params
    user_params = params[:user]
    user_params ? user_params.permit(:email, :name, :avatar, :slug, :confirmed) : {}
  end

  def required_params
    params.require(:user)
  end
end
