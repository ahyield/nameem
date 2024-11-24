Turnstile.configure do |config|
  if Rails.env.development?
    config.site_key = "0x4AAAAAAAOAckyyn9gq0dx-"
    config.secret_key = "0x4AAAAAAAOAcvTduMhIx9wnqjCXmI3hGag"
  elsif Rails.env.production?
    config.site_key = "0x4AAAAAAAOAfcGIeeju5GK1"
    config.secret_key = "0x4AAAAAAAOAfdYCw54U4WFeeiYMSNyxcro"
  end
end
