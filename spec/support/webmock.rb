require "webmock/rspec"

# Specs must not reach the internet (Resend, S3, Cloudflare, avatars...).
# Localhost stays open for the browser driver in system specs.
WebMock.disable_net_connect!(allow_localhost: true)
