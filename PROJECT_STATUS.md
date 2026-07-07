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
- Small authenticated General chat room exists.
- Chat uses persisted Postgres messages, LiveView streams, and PubSub inserts.

Not done yet:

- Presence tracking and typing indicators for chat.
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

## Deployment Handoff Notes

Current readiness:

- The application now has database-backed auth and a small authenticated General chat room.
- Local dev/test databases have the current migrations applied.
- `priv/repo/seeds.exs` creates the default General chat room idempotently.
- `mix precommit` was last verified after chat implementation with 125 tests passing.
- Phoenix release helpers and Docker deployment files have been generated.
- A Neon project/database has been created and the direct connection string has been copied outside the repository.
- Fly app `teablog` exists in the San Jose (`sjc`) region and a validated `fly.toml` is present in the repository.
- First Fly deployment succeeded at `https://teablog.fly.dev/`.
- Production migrations and the idempotent General chat room seed completed through Fly's release command.
- Fly health checks are passing on two `sjc` app machines.

Production runtime expectations:

- `DATABASE_URL` must point at the Neon Postgres connection string.
- `SECRET_KEY_BASE` must be generated with `mix phx.gen.secret`.
- `PHX_HOST` must match the production hostname.
- `PHX_SERVER=true` must be set for releases/server startup.
- `runtime.exs` already reads `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PORT`, optional `POOL_SIZE`, and optional `ECTO_IPV6`.
- Production repo config currently sets SSL CA certs for managed Postgres.
- Swoosh has no production mail provider yet. Auth can use local/test adapters, but production email delivery still needs a provider decision before real users can receive magic links or email-change links.
- The first production build surfaced security advisories for `earmark`, `hpax`, `phoenix`, and `plug`; dependency upgrades should be handled before treating the site as public-launch ready.

Suggested Fly/Neon order:

1. Generate Phoenix release and Docker deployment files with `mix phx.gen.release --docker`.
2. Review generated `Dockerfile`, `.dockerignore`, `lib/tea/release.ex`, and `rel/overlays/bin/*`.
3. Create the Neon project/database.
4. Copy a Neon direct Postgres connection string for initial `DATABASE_URL`; start with `POOL_SIZE=5`.
5. Create the Fly app and `fly.toml` without provisioning Fly Postgres.
6. Configure Fly `release_command` to run production migrations.
7. Add a production seed path or one-off release command so the General chat room exists.
8. Set Fly secrets: `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PHX_SERVER`, and `POOL_SIZE`.
9. Configure Fly health checks so production `force_ssl` does not cause redirect failures.
10. Deploy to Fly.
11. Run or verify production migrations and seeds.
12. Configure Cloudflare DNS to point the chosen hostname at Fly.
13. Revisit production email delivery before opening registration beyond personal/admin testing.

Fly/Neon details:

- Neon requires SSL for Ecto/Postgrex connections. `runtime.exs` already configures `ssl: [cacerts: :public_key.cacerts_get()]`.
- A direct Neon connection string is simplest for initial launch and migrations. If the app scales to multiple Fly Machines or sees connection pressure, switch the app runtime to Neon's pooled connection string and keep migrations/admin work on a direct connection.
- Fly health checks use an `X-Forwarded-Proto: https` header so production `force_ssl` does not cause redirect failures.
- The Fly release command runs `Tea.Release.migrate_and_seed/0`, which runs migrations and then evaluates the idempotent seed file for the default General chat room.

One important caveat before public launch: auth currently depends on email links, but Swoosh has no production mail provider configured yet. Deployment can still proceed for infrastructure testing, but real user registration/login will need email delivery before the site is truly usable by others.

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
- [x] Style auth pages with project Tailwind/CSS conventions.

### Small Chat

- [x] Add `chat_rooms` table.
- [x] Add `chat_messages` table.
- [x] Add `Tea.Chat` context.
- [x] Add `Tea.Chat.Room` schema.
- [x] Add `Tea.Chat.Message` schema.
- [x] Add a default general room seed.
- [x] Add `TeaWeb.ChatLive`.
- [x] Route `/chat` through the authenticated browser/live session.
- [x] Use LiveView streams for messages.
- [x] Use PubSub for realtime inserts.
- [x] Keep Presence and typing indicators for a follow-up pass.

### Deployment

- [x] Generate Phoenix release and Docker deployment files.
- [x] Review generated release and Docker files.
- [x] Create Neon project and database.
- [x] Copy Neon direct connection string for initial `DATABASE_URL`.
- [x] Create Fly app and `fly.toml` without Fly Postgres.
- [x] Configure Fly `release_command` for migrations.
- [x] Add production seed path for the General chat room.
- [x] Set Fly secrets: `DATABASE_URL`, `SECRET_KEY_BASE`, and `PHX_SERVER`; `PHX_HOST` and `POOL_SIZE` are configured in `fly.toml`.
- [x] Configure Fly health checks for production `force_ssl`.
- [x] Deploy to Fly.
- [x] Run production migrations and seeds.
- [ ] Address production build dependency advisories.
- [ ] Configure Cloudflare DNS.
- [ ] Configure production email delivery before public registration/login.

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
