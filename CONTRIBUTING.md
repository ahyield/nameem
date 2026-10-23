# Contributing to Nameem

Thanks for your interest in Nameem. Bug reports, fixes and improvements are welcome.

## Workflow

1. Open an issue first for anything larger than a small fix, so we can agree on the approach.
2. Fork the repo and create a branch from `main`.
3. Make your change, with specs where it makes sense.
4. Make sure `bundle exec rspec` and `bundle exec rubocop` pass.
5. Open a pull request describing what changed and why.

## Code style

- Double quotes in Ruby and JavaScript; no semicolons in JavaScript.
- Max line length is 130.
- Prefer explicit `if`/`else` over guard clauses.
- The UI is Arabic-first and right-to-left. Write user-facing copy in Arabic and check layouts in RTL.

Run `bundle exec rubocop -a` to auto-fix most style issues.
