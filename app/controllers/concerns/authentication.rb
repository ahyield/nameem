module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  private

  def authenticate_user_after_sign_up(user)
    session[:user_id] = user.id
    user.touch(:last_sign_in_at)
    Current.user = user
    redirect_to root_path
  end

  def authenticate_user!
    redirect_to root_path, alert: "يجب تسجيل الدخول أولًا!" unless user_signed_in?
  end

  def authenticate_from_session
    Current.user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def current_user
    Current.user || authenticate_from_session
  end
end
