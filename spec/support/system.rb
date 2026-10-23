require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size:     [1400, 1000],
    headless:        ENV["HEADFUL"].blank?,
    process_timeout: 30,
    timeout:         15,
    # Third-party scripts and fonts make tests slow and flaky; the app works without them
    url_blocklist:   [
      %r{platform\.twitter\.com}, %r{challenges\.cloudflare\.com}, %r{api\.digitup\.dev},
      %r{fonts\.(googleapis|gstatic)\.com}
    ],
    browser_options: ENV["CI"] ? { "no-sandbox" => nil } : {}
  )
end

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
# The test environment's asset_host is http://localhost:3001, so the app server must listen there
Capybara.server_port = 3001

module SystemHelpers
  # Signs in through the real login form and 6-digit code screen
  def system_sign_in(user)
    visit login_path
    fill_in "email", with: user.email
    click_on "تسجيل دخول"
    # Wait for the code screen, which only renders after the server has created the link
    expect(page).to have_field("code")

    code = MagicLink.where(user:).order(:created_at).last.code
    fill_in "code", with: code # the form submits itself once six characters are entered
    expect(page).to have_no_field("code")
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system

  config.before(:each, type: :system) do
    driven_by :cuprite
  end
end
