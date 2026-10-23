module Email
  # Email secrets and settings: an environment variable wins (set in .env.production, passed through Kamal),
  # otherwise Rails credentials. Read at call time so a redeploy with new env picks them up.
  module Settings
    module_function

    def resend_api_key
      ENV["RESEND_API_KEY"].presence || Rails.application.credentials.dig(:resend, :api_key)
    end

    def resend_webhook_secret
      ENV["RESEND_WEBHOOK_SECRET"].presence || Rails.application.credentials.dig(:resend, :webhook_secret)
    end

    def postal_address
      ENV["MAILER_POSTAL_ADDRESS"].presence || Rails.application.credentials.dig(:mailer, :postal_address)
    end
  end
end
