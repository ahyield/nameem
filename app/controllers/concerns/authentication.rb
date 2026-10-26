module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :authenticated?, :user_signed_in?
    before_action :require_authentication
  end

  private

  def require_authentication
    resume_session || redirect_to_login
  end

  def resume_session
    if (session_record = find_session_by_cookie)
      Current.session = session_record
      true
    end
  end

  def find_session_by_cookie
    Session.find_signed(cookies[:session_token])
  end

  def start_new_session_for(user)
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent&.first(4096)
    )
    Current.session = session_record
    cookies.permanent[:session_token] = { value: session_record.signed_id, httponly: true, same_site: :lax }
    remember_theme(user.theme)
    session_record
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_token)
    Current.session = nil
  end

  def authenticated?
    Current.user.present?
  end

  alias user_signed_in? authenticated?

  def current_user
    Current.user
  end

  def redirect_to_login
    redirect_to login_path, alert: "يجب تسجيل الدخول أولًا!"
  end
end
