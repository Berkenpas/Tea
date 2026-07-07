# Tea Project Status

Persistent planning notes for the personal blog and small community site.

## Vision

Build a small, intentionally crafted website inspired by the Web Revival and Indie Web movements:

- Personal blog
- Cozy, text-first community
- Minimal JavaScript
- Fast server-rendered pages
- Chronological content
- Small chat room and, later, forum-style community features
- Long-lived, maintainable architecture
- Low operating costs
- No dependence on large social media platforms

The site should feel like a personal website, community clubhouse, BBS, and blog with interactive features rather than a SaaS application, social media platform, or infinite-scroll content feed.

## Design And Implementation Principles

- Server-first rendering through Phoenix controllers, HEEx templates, and LiveView where interactivity is needed.
- Progressive enhancement: realtime features should improve the experience without making ordinary browsing fragile.
- Small-community focus: optimize for clarity, low cost, moderation, and maintainability before scale.
- Minimal custom JavaScript. Use LiveView and Phoenix PubSub for realtime behavior.
- Use Tailwind CSS classes and custom CSS for the visual system.
- Avoid daisyUI components for app UI. The current project includes daisyUI vendor/theme plumbing, but UI should be handcrafted with Tailwind and project CSS unless daisyUI is only helping bootstrap/theme plumbing.
- Keep the warm tea-shop / Pacific Northwest / lofi feeling without turning the interface into a one-note palette.

## Current Project Status

Done:

- Phoenix 1.8 application scaffold.
- LiveView dependency and Phoenix PubSub are present.
- Ecto/Postgres integration is wired.
- `Tea.Repo` is configured and supervised.
- Local dev/test Postgres databases have been created.
- Phoenix auth has been generated and migrated.
- Tailwind CSS v4 import syntax is in `assets/css/app.css`.
- Markdown article loading is implemented in `Tea.Blog`.
- Article categories for writings and reviews exist.
- Server-rendered home, index, and detail pages exist.
- Custom site layout and visual CSS exist.

Not done yet:

- Auth page visual polish.
- Persistent chat data model.
- Chat LiveView.
- RSS feed.
- About page.
- Fly.io release/deployment files.
- Neon production database configuration.
- Cloudflare DNS setup.

Notes:

- `mix deps.get` currently reports that `earmark` is retired. It still works for now, but a future Markdown-rendering pass should consider replacing it with a maintained package such as MDEx.
- Local Postgres is expected to be available through the `tea-postgres` Podman container on `localhost:5432`.
- Phoenix auth requires local build tooling (`make`, `gcc`) for `bcrypt_elixir` and Erlang `xmerl` headers for Swoosh. Those host dependencies are installed now.
- Swoosh's API client is disabled for now; local/test mail adapters work without choosing a production email provider yet.

## Target Stack

- Phoenix 1.8 for routing, controllers, templates, authentication, LiveView, and business logic.
- Elixir/OTP for concurrency and reliable long-running processes.
- LiveView for chat, presence, live notifications, and future interactive features.
- Tailwind CSS v4 plus custom CSS for styling.
- Earmark for Markdown rendering.
- Neon Postgres for dynamic data.
- Fly.io for hosting the Phoenix application.
- Cloudflare for DNS, HTTPS edge, CDN, and basic protection.

## Content Strategy

Initial blog content remains Markdown files in the repository, currently under `priv/articles`.

Benefits:

- Git versioning.
- Simple authoring.
- No CMS needed.
- Easy backup and migration.
- No database required for blog posts.

Future dynamic community content will use Postgres.

## Hosting Plan

Expected request path:

```text
Cloudflare
  -> Fly.io
  -> Phoenix
  -> Neon Postgres
```

Fly.io should host the Phoenix release. Neon should store dynamic data such as users, chat rooms, chat messages, sessions, comments, and future forum content.

## Near-Term Goal

Hosted blog with a small authenticated chat room.

Recommended implementation order:

1. Add Ecto/Postgres.
2. Add authentication.
3. Add one-room chat.
4. Add Fly.io deployment files.
5. Connect production to Neon.
6. Point the domain through Cloudflare.

## Active Todo

### Database Foundation

- [x] Add `:ecto_sql` and `:postgrex`.
- [x] Generate or create `Tea.Repo`.
- [x] Add `Tea.Repo` to application supervision.
- [x] Add `:tea, ecto_repos: [Tea.Repo]`.
- [x] Add local dev database config.
- [x] Add test database config.
- [x] Add production `DATABASE_URL` config for Neon.
- [x] Add local/test DB setup aliases.
- [x] Run `mix deps.get`.
- [x] Run `mix ecto.create`.
- [x] Run `mix precommit`.

### Auth

- [x] Run Phoenix auth generator.
- [x] Install local build tools for `bcrypt_elixir`: `make` and `gcc`.
- [x] Run `mix deps.get` after auth generation.
- [x] Fix local Erlang `xmerl` install so `xmerl/include/xmerl.hrl` exists.
- [x] Run `mix ecto.migrate`.
- [x] Run `MIX_ENV=test mix ecto.migrate`.
- [x] Review generated authenticated route scopes.
- [x] Ensure LiveViews use `<Layouts.app flash={@flash} current_scope={@current_scope}>` once auth scopes are present.
- [ ] Style auth pages with project Tailwind/CSS conventions.

### Small Chat

- [ ] Add `chat_rooms` table.
- [ ] Add `chat_messages` table.
- [ ] Add `Tea.Chat` context.
- [ ] Add `Tea.Chat.Room` schema.
- [ ] Add `Tea.Chat.Message` schema.
- [ ] Add a default general room seed.
- [ ] Add `TeaWeb.ChatLive`.
- [ ] Route `/chat` through the authenticated browser/live session.
- [ ] Use LiveView streams for messages.
- [ ] Use PubSub for realtime inserts.
- [ ] Keep Presence and typing indicators for a follow-up pass.

### Deployment

- [ ] Create Neon project and database.
- [ ] Copy Neon connection string.
- [ ] Generate Fly release/deployment files.
- [ ] Set Fly secrets: `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, and `PHX_SERVER`.
- [ ] Deploy to Fly.
- [ ] Run production migrations.
- [ ] Configure Cloudflare DNS.

## Initial Data Model

Users:

- `id`
- `email`
- `hashed_password`
- `confirmed_at`
- `inserted_at`
- `updated_at`

Chat rooms:

- `id`
- `name`
- `slug`
- `inserted_at`
- `updated_at`

Chat messages:

- `id`
- `room_id`
- `user_id`
- `body`
- `inserted_at`
- `updated_at`

Future forum categories:

- `id`
- `name`
- `slug`

Future forum threads:

- `id`
- `category_id`
- `user_id`
- `title`
- `inserted_at`
- `updated_at`

Future forum posts:

- `id`
- `thread_id`
- `user_id`
- `body`
- `inserted_at`
- `updated_at`

## Cost Expectations

- Cloudflare: likely free initially.
- Fly.io: likely a small shared CPU machine, roughly low single-digit dollars per month.
- Neon: likely free tier initially.
- Total: likely around a few dollars per month unless traffic, media, or database usage grows.

## Guiding Principle

Prefer server-rendered pages, minimal JavaScript, chronological content, small community interactions, simple infrastructure, low operating cost, and long-term maintainability.
