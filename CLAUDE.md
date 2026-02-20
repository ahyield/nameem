# Nameem

Arabic-language article publishing platform. "A minor wound on the arm of the absurd present."

## Tech Stack

- **Ruby 4.0.1 / Rails 8.2** (edge, from GitHub main)
- **MySQL 8.0** with binary UUIDs for articles
- **Hotwire** (Turbo + Stimulus) — no SPA, no React
- **Tailwind CSS 4.0** with RTL layout (`dir="rtl"`)
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
└── schedule.yml          # Recurring jobs (Plausible sync)
db/
├── migrate/              # Migrations
└── schema.rb             # Current schema
spec/
├── models/               # Model specs
├── requests/             # Request specs
└── support/              # auth_helpers, factory_bot
```

## Key Models

- **User** — email, slug (friendly_id), name, bio, avatar, roles (admin/editor/featured/picked/confirmed)
- **Article** — binary UUID, title, content (Lexical JSON), content_html (server-rendered HTML), published/featured/picked, counter caches (likes, comments, views, visitors)
- **ArticleLike** — user + article unique pair, counter cache
- **Comment** — Action Text body, counter cache
- **Session** — signed cookie auth tokens
- **MagicLink** — 6-digit code, expires in 15min, purpose enum (sign_in/sign_up/confirm_email)

## Auth

Passwordless magic link system:
1. User enters email → 6-digit code generated and emailed (Mailgun)
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
- CI: GitHub Actions with MySQL service container

## Integrations

- **Plausible Analytics** — article view/visitor tracking, synced via background job
- **AWS S3** — production file storage (avatars, article images)
- **Mailgun** — magic link emails
- **Sentry** — error tracking
- **Flipper** — feature flags
- **Turnstile** — CAPTCHA

## TODO

### Tags & Topics ✅
- [x] Create `Tag` model (name, slug, articles_count counter cache)
- [x] Create `ArticleTag` join model (article + tag, unique pair)
- [x] Add tag input to the publish modal (Stimulus controller with autocomplete)
- [x] Build `/topics` browse page listing all tags with article counts
- [x] Build `/topics/:slug` page showing articles for a tag
- [x] Add tag pills to article cards in feed and article show page
- [x] Add popular tags sidebar widget to feed
- [x] Backoffice: tag management (merge, rename, delete)
- [x] Specs for Tag, ArticleTag models and topics controller

### Search ✅
- [x] Add MySQL FULLTEXT index on articles (title, description)
- [x] Create `SearchController` with LIKE query + Arabic normalization against title/description
- [x] Build search bar component (Stimulus controller with debounced input)
- [x] Build `/search?q=` results page with article cards
- [x] Add search to navbar (expandable input or dedicated icon)
- [x] Handle Arabic text search quirks (diacritics, alef normalization)
- [x] Specs for search controller and edge cases

### Follow System ✅
- [x] Create `Follow` model (follower_id, followed_id, unique pair, counter caches)
- [x] Add `followers_count` and `following_count` to users
- [x] Create `FollowsController` (create/destroy via Turbo Stream)
- [x] Add follow/unfollow button to user profile page
- [x] Build `/following_feed` — articles from followed authors only
- [x] Add following feed tab to feed navigation
- [x] Show follower/following counts on user profile
- [x] Build `/:slug/followers` and `/:slug/following` pages
- [x] Specs for Follow model, controller, and feed filtering

### Notifications ✅
- [x] Create `Notification` model (recipient_id, actor_id, notifiable polymorphic, action enum, read_at)
- [x] Create `NotificationsController` (index, mark_read, mark_all_read)
- [x] Add notification bell to navbar with unread count badge (Turbo Stream updates)
- [x] Generate notifications on: like, comment, new follower, article featured/picked
- [x] Build notifications dropdown/page with grouped entries
- [x] Add email digest job (daily/weekly summary of unread notifications)
- [x] User setting to toggle email notifications
- [x] Specs for Notification model, creation callbacks, and controller

### Threaded Comments
- [ ] Add `parent_id` (self-referential) to comments
- [ ] Add `replies_count` counter cache to comments
- [ ] Update comment UI to show nested replies (max 2 levels deep)
- [ ] Add "reply" button that opens inline reply form (Turbo Frame)
- [ ] Update `CommentsController` to handle parent_id
- [ ] Add likes on comments (`CommentLike` model, counter cache)
- [ ] Sort comments: top-level by newest/popular, replies by oldest
- [ ] Specs for threaded comments and comment likes

### Author Analytics ✅
- [x] Build `/:slug/stats` page (behind authentication, own profile only)
- [x] Show per-article stats: views, visitors, likes, comments over time
- [x] Show aggregate stats: total views, total likes, top articles
- [x] Pull time-series data from Plausible for charts
- [x] Simple chart rendering (Stimulus controller with lightweight chart lib or CSS-only bars)
- [x] Add "Stats" link to user dropdown menu
- [x] Specs for stats controller authorization

### Reading Time ✅
- [x] Add `reading_time_minutes` column to articles
- [x] Calculate from content_html on save (strip HTML, count words, divide by 200 wpm for Arabic)
- [x] Display reading time on article cards and article show page
- [x] Add to Metable concern so it auto-updates with content
- [x] Backfill existing articles via `rake backfill_reading_time`
- [x] Specs for reading time calculation

### Bookmarks
- [ ] Create `Bookmark` model (user + article, unique pair, counter cache optional)
- [ ] Create `BookmarksController` (create/destroy via Turbo Stream)
- [ ] Add bookmark icon to article cards and article show page
- [ ] Build `/:slug/bookmarks` page (private, own profile only)
- [ ] Add "Bookmarks" link to user dropdown menu
- [ ] Specs for Bookmark model and controller

### Related Articles
- [ ] Show 3-4 related articles at the bottom of article show page (matched by shared tags)
- [ ] "More from this author" section on article page (other articles by same writer)
- [ ] Specs for related articles query

### Trending
- [ ] Add trending section to feed (sidebar or top area) showing articles trending this week
- [ ] Trending algorithm based on views/likes velocity (recent engagement, not just totals)
- [ ] Specs for trending scope/query

### SEO & Structured Data ✅
- [x] Add JSON-LD structured data for articles (Article schema)
- [x] Ensure proper Open Graph and Twitter Card meta tags on all pages
- [x] Generate XML sitemap (articles, topics, authors)
- [x] Handle Arabic text SEO (canonical URLs, hreflang)

### RSS Feeds
- [ ] Add RSS feed for all published articles (`/feed.xml`)
- [ ] Add per-author RSS feed (`/:slug/feed.xml`)
- [ ] Add per-topic RSS feed (`/topics/:slug/feed.xml`)
- [ ] Add RSS autodiscovery link tags to relevant pages

### Personalized Recommendations
- [ ] "Based on what you've liked" — articles sharing tags with user's liked articles, excluding read
- [ ] Surface recommendations on feed page or dedicated section
- [ ] Specs for recommendation query

### Curated Collections
- [ ] Create `Collection` model (title, description, slug, editor-curated)
- [ ] Create `CollectionArticle` join model (collection + article, with position/order)
- [ ] Build `/collections` browse page and `/collections/:slug` detail page
- [ ] Backoffice: collection management (create, add/remove/reorder articles)
- [ ] Specs for Collection model and controller

### Test Coverage
- [ ] Model specs: Article (scopes, Metable, publishing logic), User (roles, slug generation)
- [ ] Request specs: full auth flow (signup, login, magic link expiry, logout)
- [ ] Request specs: article CRUD (create, edit, publish, delete, authorization)
- [ ] Request specs: likes and comments (create, delete, counter caches)
- [ ] Request specs: feed variants (latest, popular, picked)
- [ ] Request specs: backoffice access control
- [ ] Request specs: API endpoints (article JSON, attachments)
- [ ] Add SimpleCov minimum coverage threshold to CI

## Important Notes

- Arabic-first: default locale is `:ar`, all UI is RTL
- Article content stored as Lexical EditorState JSON (`content`) + server-rendered HTML (`content_html`)
- Articles use binary UUIDs (16 bytes) as public identifiers, not auto-increment IDs
- Fonts: Noto Naskh Arabic (primary), Montserrat (secondary)
- Production: Hetzner server (203.0.113.10), DB on separate server (203.0.113.20)
