# Run the full check locally with bin/ci before opening a pull request.
# GitHub Actions runs the same commands as separate jobs (.github/workflows/ci.yml).

CI.run do
  step "Setup", "(bundle check || bundle install) && npm ci --silent"

  step "Style: Ruby", "bin/rubocop"
  step "Style: ERB", "bin/erb_lint --lint-all"
  step "Style: JavaScript", "npm run lint:js --silent"

  step "Security: Brakeman", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap audit", "bin/importmap audit"

  step "Tests: JavaScript", "npm test --silent"
  step "Tests: Ruby", "env COVERAGE_FLOOR=1 bundle exec rspec"
end
