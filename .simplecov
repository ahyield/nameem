require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.single_report_path = "coverage/lcov.info"
end

SimpleCov.start "rails" do
  enable_coverage :branch
  # Count every app file, not only the ones the suite happens to load
  cover "{app,lib}/**/*.rb"

  skip %r{^/(spec|config|db|vendor|bin)/}

  group "Policies", "app/policies"
  group "Helpers", "app/helpers"

  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::LcovFormatter
                                                     ])

  # The floor only moves up: raise it whenever the suite improves.
  # Changed lines in pull requests are held to full coverage separately by undercover.
  minimum_coverage line: 92, branch: 75 if ENV["COVERAGE_FLOOR"]
end
