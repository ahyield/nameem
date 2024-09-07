source "https://rubygems.org"

ruby "3.3.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main" # YOLO
gem "rails", github: "rails/rails", branch: "main"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use mysql as the database for Active Record
gem "mysql2"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "font-awesome-rails"
gem "rails_heroicon"
gem "tailwindcss-rails"

gem "bcrypt"

gem "pundit"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "aws-sdk-s3"

gem "rexml"

gem "mysql-binuuid-rails"

gem "pagy"

gem "rails-i18n"

gem "friendly_id"
gem "name_of_person"

gem "image_processing", ">= 1.13"
gem "mini_magick"

gem "mailgun-ruby"

gem "dotenv-rails"

gem "meta-tags"

gem "flipper"
gem "flipper-active_record"

# Background with solid queue
gem "mission_control-jobs"
gem "solid_queue"

gem "sentry-rails"
gem "sentry-ruby"

gem "honeybadger"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails"

  gem "factory_bot_rails"
end

group :development, :rubocop do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "erb_lint", require: false
  gem "rack-mini-profiler"
  gem "rubocop"
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false

  gem "rubocop-performance", require: false

  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "capybara-screenshot"
  gem "capybara-selenium"

  gem "faker"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-console", require: false
  gem "timecop"
  gem "webdrivers"
end
