---
title: Owner Guide: Running and Growing Your Tea Blog
excerpt: A practical guide for adding writings, reviews, running locally, and extending your site.
date: 2026-05-19
category: writing
tags: tea, indie web, lofi, phoenix
---

# Owner Guide

Welcome to your tea-themed Phoenix blog starter. This post is your quick operating manual.

## 1) How to run the website locally

From the project root:

```bash
mix deps.get
mix phx.server
```

Then open `http://localhost:4000`.

## 2) How to add a new writing

All writings and reviews live in `priv/articles`.

1. Create a new `.md` file in that folder.
2. Name it using the URL slug you want, for example `my-second-writing.md`.
3. Add frontmatter at the top.
4. Write your markdown content below it.

Use this frontmatter format:

```md
---
title: My Second Writing
excerpt: One sentence summary shown on the writings page.
date: 2026-05-19
tags: tea, notes, devlog
---
```

Writings are the default category. To publish a review, add `category: review` to the frontmatter:

```md
---
title: Old Reliable
excerpt: A review of a familiar daily drinker.
date: 2026-05-19
category: review
tags: tea, review
---
```

The filename becomes the route:

- `priv/articles/my-second-writing.md` -> `/writings/my-second-writing`
- `priv/articles/old-reliable.md` with `category: review` -> `/reviews/old-reliable`

## 3) How the blog pages are wired

- `GET /` is your home page.
- `GET /writings` lists markdown writings.
- `GET /writings/:slug` renders a single writing as HTML.
- `GET /reviews` lists markdown reviews.
- `GET /reviews/:slug` renders a single review as HTML.
- `GET /articles` and `GET /articles/:slug` redirect to the writing routes for compatibility.

Core files:

- `lib/tea/blog.ex` loads and parses markdown.
- `lib/tea_web/controllers/blog_controller.ex` handles routes.
- `lib/tea_web/controllers/blog_html/index.html.heex` renders the writings and reviews lists.
- `lib/tea_web/controllers/blog_html/show.html.heex` renders one writing or review page.

## 4) How to customize the design

Main style file:

- `assets/css/app.css`

You can change:

- Theme colors (daisyUI variables)
- Body fonts and typography
- Markdown body styles (`.article-body`)

## 5) Good next upgrades

Suggested improvements:

1. Add pagination on the writings and reviews lists.
2. Add draft support in frontmatter (`draft: true`).
3. Add reading time calculation.
4. Add RSS feed generation.
5. Add syntax highlighting themes for code blocks.

## 6) Before deploying

Run:

```bash
mix format
mix test
```

Ship small updates often, and keep writing.
