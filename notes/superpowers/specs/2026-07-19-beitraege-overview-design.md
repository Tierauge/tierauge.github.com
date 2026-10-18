# Beiträge-Übersichtsseite: Design Spec

Date: 2026-07-19
Status: Approved by user, ready for implementation planning

## Problem

The site has three separate content sections — `wissensbank`, `patientengeschichten`,
`vortraege` (Vorträge/Poster/Publikationen) — each with its own list page. There is no single
place that shows all articles across the three areas together. The existing
`layouts/wissensbank/list.html` custom template already unions `wissensbank` + `vortraege` with
tag filtering, but `patientengeschichten` is not included anywhere, and there's no concept of
"category" distinct from which folder a page lives in.

Goal: a single overview page at `/beitraege/` that lists articles from all three sections,
grouped/filterable by category and by tag, styled after the reference
(https://liascript.github.io/blog/ — sidebar with categories + counts, plus a tag list, next to
the article list).

## Decisions from brainstorming

- The new page **replaces** the three old section list pages (they will 404 / not render); it
  does not sit alongside them.
- Individual article URLs (`/wissensbank/glaukom/`, `/patientengeschichten/abby/`, etc.) **do
  not change**. No redirects needed for those.
- The new page lives at **`/beitraege/`** (new, neutral path — not reusing `/wissensbank/`).
- Category is **not** inferred from the folder/section. It's an explicit front-matter field
  (`categories: [...]`) on every article, same pattern as the existing `tags` field, so a page's
  category is independent of which content folder it physically lives in and — in principle —
  a page could carry more than one category.
- `data/categories.yaml` is the master taxonomy: defines the valid category keys, their
  display label, a short description, and their display order. It does not itself list pages —
  membership is per-article via the front-matter field.
- Layout is a two-column sidebar layout (categories with counts + tag list on the left,
  article grid on the right), not the current top filter-bar layout.
- Tag selection stays **single-select** (click a tag, replaces the previous selection),
  combined with the category selection via AND — same interaction model the current
  `wissensbank/list.html` already uses for its filter buttons, just relocated into the sidebar.
- Tags need to be back-filled: most `wissensbank` articles and both `patientengeschichten`
  articles currently have no `tags`. Claude proposes tags per article (content-based), user
  reviews/edits before they're committed.

## 1. Data model

### `data/categories.yaml` (new)

Ordered list — order in the file is display order:

```yaml
- key: wissensbank
  label: "Wissensbank"
  description: "Informationen über gängige Augenerkrankungen"
- key: patientengeschichten
  label: "Patientengeschichten"
  description: "Ausgewählte Fallberichte aus der Praxis"
- key: vortraege
  label: "Vorträge, Poster, Publikationen"
  description: "Fortbildungen und Fachtagungen"
```

### Article front matter (all existing + future articles in the three sections)

Add a `categories` array, array-typed even though in practice each article will normally carry
exactly one value:

```yaml
categories: ["wissensbank"]
```

Existing `tags: [...]` front matter is unchanged in shape; only back-filled where missing.

Rollout: every existing article under `content/wissensbank/`, `content/patientengeschichten/`,
`content/vortraege/` (≈30 files) gets a `categories` entry matching its current folder (i.e. no
behavior change from today, just made explicit). Tags are proposed per-article by Claude and
reviewed by the user before committing.

## 2. Retiring the old section list pages

`content/wissensbank/_index.md`, `content/patientengeschichten/_index.md`,
`content/vortraege/_index.md` each get:

```yaml
_build:
  render: "never"
```

This stops Hugo from emitting `/wissensbank/`, `/patientengeschichten/`, `/vortraege/` as
pages, while child articles keep rendering at their existing URLs and remain part of
`site.RegularPages` for the given section (needed for the union query below).

`themes/celadon/layouts/wissensbank/list.html` (the current custom union-listing template) is
deleted — its functionality is superseded by the new `beitraege` layout.

## 3. New section: `/beitraege/`

### `content/beitraege/_index.md` (new)

```yaml
---
title: "Beiträge"
layout: "beitraege"
---
```

### `themes/celadon/layouts/beitraege/list.html` (new)

Two-column layout:

- **Sidebar** (left):
  - Category list, sourced from `data/categories.yaml`, each showing `label` and a count of
    matching articles; "Alle" option at the top showing the total. Single-select (radio-like),
    default "Alle".
  - Tag list below: unique tags collected across all included articles (same `uniq | sort`
    pattern as today), rendered as chips, single-select, default "Alle". No counts on tags
    (matches the reference site's tag-cloud treatment).
- **Article grid** (right): reuses the existing `listing-grid` / card markup and the
  card/list/compact view toggle already built for the current listing, so no new grid/card CSS
  is needed beyond what's below.

### Page source

```go-html-template
{{ $pages := (where site.RegularPages "Section" "wissensbank") |
    union (where site.RegularPages "Section" "patientengeschichten") |
    union (where site.RegularPages "Section" "vortraege") }}
{{ $pages = $pages.ByDate.Reverse }}
```

Categories and tags used for filtering come from each page's `.Params.categories` /
`.Params.tags`, not from `.Section` — the union above is just "which folders do we pull
articles from," independent of the category filtering UI.

### Filtering behavior (client-side JS, extending the existing pattern)

- Each card gets `data-categories="wissensbank"` (space/comma-joined, same style as the
  existing `data-tags`) and keeps `data-tags="..."`.
- Two filter state variables: active category (default `all`), active tag (default `all`).
- A card is visible iff `(activeCategory == 'all' || card has activeCategory)
  && (activeTag == 'all' || card has activeTag)`.
- Clicking a category/tag chip sets that dimension's active value and re-applies the combined
  filter (does not reset the other dimension).
- View toggle (card/list/compact), including its `localStorage` persistence, is unchanged from
  the current implementation.

## 4. Card design

Same card markup as today (thumbnail, date, title, excerpt, tag row, "Weiterlesen →"), plus a
small category badge/chip near the title showing the article's category label(s) from
`categories.yaml` — needed because once "Alle" is selected, cards from all three areas are
mixed together and the category is otherwise not visible.

## 5. Navigation (`hugo.toml`)

`[params.nav.extraLinks]`: remove the `Wissensbank`, `Patientengeschichten`, and
`Vorträge, Poster, Publikationen` entries; add a single entry:

```toml
[[params.nav.extraLinks]]
  title = "Beiträge"
  url = "/beitraege/"
```

`Impressum` entry stays as-is.

## 6. CSS

Extends `themes/celadon/assets/css/main.css`. New rules needed: sidebar container/layout
(two-column grid, collapsing to stacked on mobile), category list item + active state (can
mostly reuse `.filter-btn` styling), category badge on cards. Existing `.listing-grid`,
`.listing-card`, `.tag`, `.tag-row`, view-toggle styles are reused unchanged.

## 7. Documentation

Update `site-tierauge/CLAUDE.md`'s "Vendored theme divergence" section: remove the
`wissensbank/list.html` bullet (file no longer exists), add a bullet for the new `beitraege`
section/layout and the `_build.render: never` pattern on the three old section indexes.

## Out of scope

- No redirects for the old `/wissensbank/`, `/patientengeschichten/`, `/vortraege/` list URLs
  (only the article URLs need to keep working, and they already do).
- No pagination (article count is small; not needed at current or near-future scale).
- No multi-select tag filtering (single-select only, matching current UX).
- No icons/colors per category (label + description only).
