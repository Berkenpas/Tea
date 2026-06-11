---
title: Owner Guide: Running and Growing Your Tea Blog
excerpt: A practical guide for adding articles, running locally, and extending your site.
date: 2026-05-19
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

## 2) How to add a new article

All articles live in `priv/articles`.

1. Create a new `.md` file in that folder.
2. Name it using the URL slug you want, for example `my-second-post.md`.
3. Add frontmatter at the top.
4. Write your markdown content below it.

Use this frontmatter format:

```md
---
title: My Second Post
excerpt: One sentence summary shown on the articles page.
date: 2026-05-19
tags: tea, notes, devlog
---
```

The filename becomes the route:

- `priv/articles/my-second-post.md` -> `/articles/my-second-post`

## 3) How the blog pages are wired

- `GET /` is your home page.
- `GET /articles` lists all markdown posts.
- `GET /articles/:slug` renders a single markdown file as HTML.

Core files:

- `lib/tea/blog.ex` loads and parses markdown.
- `lib/tea_web/controllers/blog_controller.ex` handles routes.
- `lib/tea_web/controllers/blog_html/index.html.heex` renders the article list.
- `lib/tea_web/controllers/blog_html/show.html.heex` renders one article page.

## 4) How to customize the design

Main style file:

- `assets/css/app.css`

You can change:

- Theme colors (daisyUI variables)
- Body fonts and typography
- Markdown article styles (`.article-body`)

## 5) Good next upgrades

Suggested improvements:

1. Add pagination on the articles list.
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
