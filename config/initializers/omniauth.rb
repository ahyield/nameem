Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], { provider_ignores_state: true }, callback_url: callback_url

  on_failure do |env|
    CallbacksController.action(:failure).call(env)
  end

end

def callback_url
  if Rails.env.production?
    "https://nameem.com/auth/facebook/callback"
  elsif Rails.env.staging?
    "https://staging.nameem.com/auth/facebook/callback"
  else
    "http://localhost:3000/auth/facebook/callback"
  end
end
