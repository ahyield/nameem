module AuthHelpers
  def sign_in(user)
    session[:user_id] = user.id
    Current.user = user
  end

  def sign_out
    session.delete(:user_id)
    Current.user = nil
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
end
