require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "pundit/rspec"

Rails.root.glob("spec/support/**/*.rb").sort.each { |file| require file }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Views link the Tailwind build; compile it once if it's missing. Never precompile into
  # public/assets here: a stale manifest there makes development serve old CSS.
  config.before(:suite) do
    unless Rails.root.join("app/assets/builds/tailwind.css").exist?
      system("bin/rails", "tailwindcss:build", exception: true, out: File::NULL)
    end

    ActiveJob::Base.queue_adapter = :inline
  end

  config.include ActiveJob::TestHelper

  config.fixture_paths = [Rails.root.join("spec/fixtures").to_s]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
