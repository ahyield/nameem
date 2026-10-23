# Nameem

Arabic-language article publishing platform. "A minor wound on the arm of the absurd present."

## Tech Stack

- **Ruby 4.0.8 / Rails 8.2** (edge, from GitHub main)
- **MySQL 8.0** with binary UUIDs for articles
- **Hotwire** (Turbo + Stimulus) — no SPA, no React
- **Tailwind CSS 3.4** (`tailwindcss-rails`, `config/tailwind.config.js`) with RTL layout (`dir="rtl"`)
- **Lexical** (Meta) for article editor (EditorState JSON + HTML dual storage)
- **ImportMap** for JS modules (no bundler)
- **Solid Queue** for background jobs
- **Kamal** for Docker deployment to Hetzner

## Commands

```bash
bin/dev                    # Start dev (web + css + jobs via Foreman)
bin/rails server           # Rails only
bundle exec rspec          # Run all specs
bundle exec rspec spec/models/article_spec.rb  # Run specific spec
bundle exec rubocop        # Lint Ruby
bundle exec rubocop -a     # Auto-fix
```

## Project Structure

```
app/
├── controllers/
│   ├── api/              # JSON endpoints for Lexical editor
│   ├── backoffice/       # Admin dashboard
│   ├── concerns/         # Authentication concern
│   └── sessions/         # Magic link auth flow
├── models/
│   └── concerns/         # Metable (auto-extract description/images)
├── javascript/
│   ├── controllers/      # Stimulus controllers
│   └── lib/              # Lexical config, custom nodes, API helpers
├── jobs/                 # Solid Queue jobs
├── mailers/              # Magic link emails
├── policies/             # Pundit authorization
└── views/                # ERB templates
config/
├── routes.rb             # Main routes
├── routes/backoffice.rb  # Admin routes
├── deploy.yml            # Kamal base config
└── schedule.yml          # Recurring jobs
db/
├── migrate/              # Migrations
└── schema.rb             # Current schema
spec/
├── models/               # Model specs
├── requests/             # Request specs
└── support/              # auth_helpers, factory_bot
```

## Key Models

- **User** — email, slug (friendly_id), name, bio, avatar, roles (admin/editor/featured/picked/confirmed), followers_count, following_count
- **Article** — binary UUID, title, content (Lexical JSON), content_html (server-rendered HTML), published/featured/picked, reading_time_minutes, counter caches (likes, comments, views, visitors)
- **ArticleLike** — user + article unique pair, counter cache
- **Comment** — Action Text body, parent_id (threaded), replies_count, counter cache
- **CommentLike** — user + comment unique pair, counter cache
- **Tag** — name, slug, articles_count counter cache
- **ArticleTag** — article + tag unique pair
- **Follow** — follower_id + followed_id unique pair, counter caches
- **Notification** — recipient_id, actor_id, notifiable (polymorphic), action enum, read_at
- **Bookmark** — user + article unique pair
- **Session** — signed cookie auth tokens
- **MagicLink** — 6-digit code, expires in 15min, purpose enum (sign_in/sign_up/confirm_email)

## Auth

Passwordless magic link system:
1. User enters email → 6-digit code generated and emailed (Resend)
2. User enters code → session created with signed cookie
3. `Current.user` / `Current.session` via thread-local `Current` attributes
4. Pundit policies for authorization

## Routing Pattern

User profiles and articles live under `/:slug` and `/:slug/:uuid`:
- `/:slug` — user profile
- `/:slug/:uuid` — article (UUID constraint)
- `/:slug/:uuid/edit` — edit article
- `/new-story` — create article
- `/feed` — main feed (with `/latest_feed`, `/popular_feed`, `/picked_feed` variants)
- `/backoffice/*` — admin (AdminConstraint)
- `/api/*` — JSON endpoints for editor

## Code Style

- **Double quotes** everywhere (Ruby and JS)
- **No frozen_string_literal** comments
- **Max line length**: 130
- **Hash alignment**: table style (`:` aligned)
- **No semicolons** in JS
- Rubocop with rubocop-rails, rubocop-rspec, rubocop-performance
- Guard clause style disabled (use explicit if/else)

## Testing

- **RSpec** with FactoryBot, Shoulda Matchers, Faker, Timecop
- `authenticate_user(user)` helper in request specs
- `json` helper to parse response body
- Transactional fixtures enabled

## Integrations

- **AWS S3** — production file storage (avatars, article images)
- **Resend** — transactional emails
- **Flipper** — feature flags
- **Turnstile** — CAPTCHA on sign-up

## Completed Features

Tags & Topics, Search, Follow System, Notifications, Threaded Comments, Author Analytics, Reading Time, Bookmarks, Related Articles, Trending, SEO & Structured Data

## Important Notes

- Arabic-first: default locale is `:ar`, all UI is RTL
- Article content stored as Lexical EditorState JSON (`content`) + server-rendered HTML (`content_html`)
- Articles use binary UUIDs (16 bytes) as public identifiers, not auto-increment IDs
- Fonts: Noto Naskh Arabic (primary), Montserrat (secondary)
- Production: Hetzner via Kamal; server and DB hosts come from `WEB_HOST` / `DB_HOST` env vars
