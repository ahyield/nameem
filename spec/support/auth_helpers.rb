module AuthHelpers
  # Signs the user in for controller and request specs by setting the session cookie
  def sign_in(user)
    session_record = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    cookies[:session_token] = session_record.signed_id
    Current.session = session_record
    Current.user = user
  end
  alias authenticate_user sign_in

  def sign_out
    Current.session&.destroy
    cookies.delete(:session_token)
    Current.session = nil
    Current.user = nil
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :request
end
