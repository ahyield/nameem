module AuthHelpers
  def sign_in(user)
    session_record = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    cookies[:session_token] = session_record.signed_id
    Current.session = session_record
    Current.user = user
  end

  def sign_out
    Current.session&.destroy
    cookies.delete(:session_token)
    Current.session = nil
    Current.user = nil
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
end
