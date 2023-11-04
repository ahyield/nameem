Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], { provider_ignores_state: true }

  on_failure do |env|
    CallbacksController.action(:failure).call(env)
  end
end
