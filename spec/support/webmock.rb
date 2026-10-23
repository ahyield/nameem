require "webmock/rspec"

# Specs must not reach the internet (Resend, S3, Cloudflare, avatars...).
WebMock.disable_net_connect!(allow_localhost: true)
