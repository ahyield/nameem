module Webhooks
  # Resend posts delivery events here (signed with Svix). Hard bounces and spam complaints stop
  # all but account mail to that address.
  class ResendController < ActionController::API
    TOLERANCE = 5.minutes

    before_action :verify_signature

    def create
      event = JSON.parse(request.raw_post)
      reason = suppression_reason(event)
      Array(event.dig("data", "to")).each { |address| suppress(address, reason) } if reason
      head :ok
    rescue JSON::ParserError
      head :bad_request
    end

    private

    def suppression_reason(event)
      case event["type"]
      when "email.complained" then "complaint"
      when "email.bounced" then "bounce" unless event.dig("data", "bounce", "type").to_s.casecmp?("transient")
      end
    end

    def suppress(address, reason)
      User.find_by(email: address.to_s.downcase)&.suppress_email!(reason)
    end

    # https://docs.svix.com/receiving/verifying-payloads/how-manual
    def verify_signature
      head :unauthorized unless signed_by_resend?
    end

    def signed_by_resend?
      secret = Rails.application.credentials.dig(:resend, :webhook_secret)
      id, timestamp, signatures = %w[svix-id svix-timestamp svix-signature].map { |name| request.headers[name] }
      return false if [secret, id, timestamp, signatures].any?(&:blank?)
      return false if (Time.current.to_i - timestamp.to_i).abs > TOLERANCE

      expected = signature_for(secret, "#{id}.#{timestamp}.#{request.raw_post}")
      signatures.split.any? { |entry| ActiveSupport::SecurityUtils.secure_compare(entry.delete_prefix("v1,"), expected) }
    end

    def signature_for(secret, payload)
      key = Base64.decode64(secret.delete_prefix("whsec_"))
      Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", key, payload))
    end
  end
end
