Rails.application.config.after_initialize do
  Resend.api_key = Email::Settings.resend_api_key
end
