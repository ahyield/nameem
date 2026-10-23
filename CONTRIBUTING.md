# Contributing to Nameem

Thanks for your interest in Nameem. Bug reports, fixes and improvements are welcome.

## Workflow

1. Open an issue first for anything larger than a small fix, so we can agree on the approach.
2. Fork the repo and create a branch from `main`.
3. Make your change, **with specs**. New or changed behavior needs specs: CI fails a pull request when the lines it changes aren't covered.
4. Run `bin/ci` and make sure it passes. It runs the same checks as GitHub Actions.
5. Open a pull request using the template, and attach screenshots for UI changes.

`main` only accepts pull requests with all checks green (`lint`, `security`, `js`, `specs`).

## Tests

- **Request specs** (`spec/requests`) for controller behavior, **model specs** for domain logic, **policy specs** for authorization.
- **JavaScript unit tests** (`spec/javascript/*.test.js`) for plain modules in `app/javascript/lib`.
- Specs never reach the internet: WebMock blocks outside HTTP, and factories use local fixture files.

## Code style

- Double quotes in Ruby and JavaScript; no semicolons in JavaScript.
- Max line length is 130.
- Prefer explicit `if`/`else` over guard clauses.
- The UI is Arabic-first and right-to-left. Write user-facing copy in Arabic and check layouts in RTL.

Run `bin/rubocop -a` and `bin/erb_lint --lint-all -a` to auto-fix most style issues.
