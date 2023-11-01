module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_from_session

    helper_method :current_user, :user_signed_in?
  end

  private

  def authenticate_from_session
    if authenticated_user = User.find_by(id: session[:user_id])
      Current.user = authenticated_user
    else
      # redirect_to new_session_url
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def current_user
    Current.user || authenticate_from_session
  end
end
