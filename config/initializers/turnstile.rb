Turnstile.configure do |config|
  if Rails.env.production?
    config.site_key = Rails.application.credentials.dig(:turnstile, :site_key)
    config.secret_key = Rails.application.credentials.dig(:turnstile, :secret_key)
  else
    # Cloudflare's test keys: the widget always passes and needs no account.
    # https://developers.cloudflare.com/turnstile/troubleshooting/testing/
    config.site_key = "1x00000000000000000000AA"
    config.secret_key = "1x0000000000000000000000000000000AA"
  end

  # Tests never call Cloudflare; specs that cover the captcha stub valid_captcha? instead
  config.enabled = !Rails.env.test?
end
