Turnstile.configure do |config|
  if Rails.env.development?
    config.site_key = "***REMOVED***"
    config.secret_key = "***REMOVED***"
  elsif Rails.env.production?
    config.site_key = "***REMOVED***"
    config.secret_key = "***REMOVED***"
  end
end
