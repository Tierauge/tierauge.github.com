# Seitensuche: Design Spec

Date: 2026-07-29
Status: Approved by user, ready for implementation planning

## Problem

The site has no way to search across content. Visitors can only find articles via nav links,
the `/wissen/` overview page (which itself only lists `wissensbank` + `patientengeschichten` +
`vortraege`), or the `augenheilkunde` sub-grid. There's no way to search standalone pages
(`ueber-mich`, `augenoperationen`, `standorte-kontakt`, `fuer-tieraerzte`, `impressum`,
`datenschutz`) at all.

Goal: a real full-text search across the whole site, reachable from a search icon in the nav on
every page, showing a thumbnail (when the page has one) and a text snippet with the matched term
highlighted per result.

## Decisions from brainstorming

- **Scope**: the whole site, not just the three "Beiträge" content types. Includes the home
  page, the `augenheilkunde` overview + its sub-pages, all `wissensbank` /
  `patientengeschichten` / `vortraege` articles, and the standalone service/legal pages
  (`ueber-mich`, `augenoperationen`, `standorte-kontakt`, `fuer-tieraerzte`, `impressum`,
  `datenschutz`).
- **Excluded**: the three `render: never` section index pages (`wissensbank/_index.md`,
  `patientengeschichten/_index.md`, `vortraege/_index.md` — not reachable, no permalink to send
  users to) and taxonomy/term (tag) pages (auto-generated listings, no unique content of their
  own).
- **Entry point**: a search icon button in the nav, placed as a sibling of `.nav-toggle` (i.e.
  outside `.nav-menu`) so it stays visible in both the expanded and hamburger-collapsed nav
  states, on every page, desktop and mobile. No separate `/suche/` page and no duplicate entry
  in the mobile action bar — the sticky nav already reaches every page.
- **Overlay**: a native `<dialog>` element opened via `showModal()`, giving Escape-to-close,
  focus trapping, and backdrop-click-to-close for free instead of hand-rolled JS for those.
- **Index/thumbnail rule**: thumbnail shown only when the page's `image`/`thumbnail` param is
  set — no fallback placeholder image (unlike the `/wissen/` cards, which default to
  `/images/profile.jpg`). Most standalone pages have no image and will render as text-only
  result rows.
- **No external search library** (no Fuse.js, no Pagefind, no CDN dependency) — the index is
  small (~50 pages of short educational content), so plain-JS substring matching is enough and
  keeps the site's zero-npm-build-step, mostly-self-hosted-assets approach intact.
- **i18n**: new UI strings for the search feature go through `{{ T }}` / `i18n/*.yaml`, following
  the existing convention for nav-level chrome (`nav_toggle_aria`, `theme_toggle_aria`), not the
  hardcoded-German convention used specifically in `list.html`/`single.html`.

## 1. Search index: `/index.json`

### `hugo.toml`

Enable Hugo's built-in `JSON` output format on the home page in addition to `HTML`:

```toml
[outputs]
  home = ["HTML", "JSON"]
```

### `themes/celadon/layouts/index.json.json` (new)

Builds a JSON array, one object per searchable page:

```go-html-template
{{- $excludedSections := slice "wissensbank" "patientengeschichten" "vortraege" -}}
{{- $pages := where site.Pages "Kind" "in" (slice "page" "home" "section") -}}
{{- $items := slice -}}
{{- range $pages -}}
  {{- if not (and .IsSection (in $excludedSections .Section)) -}}
    {{- $image := .Params.thumbnail | default .Params.image | default "" -}}
    {{- $items = $items | append (dict
        "title" .Title
        "url" .RelPermalink
        "image" $image
        "description" (.Description | default .Summary | default "")
        "content" .Plain
      ) -}}
  {{- end -}}
{{- end -}}
{{ $items | jsonify }}
```

Notes:
- `.Plain` is used **unabridged** (no `truncate`) so a search match late in a long article is
  still found and can still get a real snippet around it — the trade-off is a larger `/index.json`
  payload, judged acceptable given the site's actual content volume and that it's fetched lazily
  (see below), not on every page load.
- `image` resolution mirrors `layouts/wissen/list.html`'s `or .Params.thumbnail .Params.image`
  pattern, but **without** its `/images/profile.jpg` fallback — an empty string means "no
  thumbnail" and the client renders a text-only row.
- Home page content (`.Plain` on the data-driven homepage) will be thin/empty since it's
  section-partial-driven, not markdown — that's fine, its `title`/`description` still make it
  findable by name.

## 2. UI

### Nav button (`themes/celadon/layouts/_default/baseof.html`)

New icon button markup, placed between the existing `.nav-toggle` button and `.nav-menu` (or
immediately before `.nav-toggle` — exact ordering is a small implementation detail), styled like
the existing circular icon buttons (`.nav-toggle`, `.theme-toggle`):

```html
<button
  class="nav-search-toggle"
  id="nav-search-toggle"
  type="button"
  aria-label="{{ T "search_aria" }}"
>
  <!-- tabler: search svg -->
</button>
```

This button is a **sibling** of `.nav-menu`, not a child of it, so it is unaffected by the
JS-driven `nav-collapsed` hamburger logic and stays visible in both nav states.

### Dialog (`themes/celadon/layouts/_partials/components/search.html`, new)

New partial, included once from `baseof.html` (same pattern as
`partial "components/mobile-action-bar.html" .`):

```html
<dialog id="search-dialog" class="search-dialog" aria-label="{{ T "search_aria" }}">
  <div class="search-panel">
    <div class="search-input-row">
      <!-- tabler: search svg (decorative, aria-hidden) -->
      <input
        type="search"
        id="search-input"
        class="search-input"
        placeholder="{{ T "search_placeholder" }}"
        aria-label="{{ T "search_placeholder" }}"
        autocomplete="off"
      >
      <button type="button" id="search-close" aria-label="{{ T "search_close_aria" }}">
        <!-- tabler: x svg -->
      </button>
    </div>
    <div id="search-results" class="search-results" aria-live="polite"></div>
  </div>
</dialog>
```

Own inline `<script>` at the bottom of the same partial (matching how `layouts/wissen/list.html`
keeps its filter/view-toggle script alongside its own markup, rather than centralizing it in
`foot/scripts.html`):

- Click on `#nav-search-toggle` → `searchDialog.showModal()`, lazy-`fetch("/index.json")` on
  first open only (cached in a module-level variable after), focus the input.
- Click on `#search-close`, or native dialog `close`/backdrop-click/Escape → nothing extra
  needed beyond native `<dialog>` behavior, except resetting the input + results on next open (or
  leaving state — minor call, will decide in planning if it matters).
- Input handler, debounced ~150ms:
  - Empty query → clear results, no message.
  - Non-empty → split query into lowercase words, score each index item:
    - all words must appear in `title + " " + description + " " + content` (AND across words,
      substring match, `String.prototype.toLowerCase()` — good enough for the German content
      here, no accent/diacritic normalization needed beyond that).
    - weight: match in `title` > match in `description` > match in `content` only, so more
      relevant pages sort first.
  - No matches → render `{{ T "search_no_results" }}` (with the query interpolated client-side).
  - Matches → render up to ~20 result rows: thumbnail `<img>` (only if `image` is non-empty),
    title (linked), snippet — extracted as ~140 characters of `content` centered on the first
    matched word's position (falling back to `description` if the match was only in
    title/description, not body), with the matched word wrapped in `<mark>`.
- Clicking a result, or pressing Enter with results present, navigates to that page's `url`.

## 3. i18n (`themes/celadon/i18n/{de,en,pl}.yaml`)

New keys, added to all three files (matching the existing `nav_toggle_aria` /
`theme_toggle_aria` pattern — this site only ships German content, but the vendored theme keeps
all three language files in sync per existing convention):

| key | de | en | pl |
|---|---|---|---|
| `search_aria` | "Suche öffnen" | "Open search" | "Otwórz wyszukiwanie" |
| `search_placeholder` | "Suchen…" | "Search…" | "Szukaj…" |
| `search_no_results` | "Keine Ergebnisse gefunden" | "No results found" | "Brak wyników" |
| `search_close_aria` | "Suche schließen" | "Close search" | "Zamknij wyszukiwanie" |

## 4. CSS (`themes/celadon/assets/css/main.css`)

New rules needed:
- `.nav-search-toggle` — circular icon button, same treatment as `.nav-toggle`/`.theme-toggle`.
- `.search-dialog` + native `::backdrop` — centered panel, max-width, rounded corners, dark-mode
  variant (matches `body[data-theme="dark"]` pattern used elsewhere, e.g. `.morandi-nav`).
- `.search-input-row`, `.search-input` — simple input row with icon + close button.
- `.search-results`, result row (`.search-result`) — thumbnail (fixed small size, only rendered
  when present), title, snippet with `<mark>` styling consistent with existing highlight/badge
  colors (reuse `--color-primary`/`--color-accent` tokens rather than introducing new ones).
- Mobile: dialog should be full-width/near-full-height on small viewports rather than a small
  centered box (consistent with the site's existing mobile-specific CSS overrides documented in
  `site-tierauge/CLAUDE.md`).

## 5. Documentation

Update `site-tierauge/CLAUDE.md`'s "Vendored theme divergence" section with a bullet describing
the new search feature (`/index.json` output, `components/search.html` partial, nav button
placement) so future changes to `baseof.html`/`hugo.toml` don't accidentally break it.

## Out of scope

- No fuzzy/typo-tolerant matching, no external search library (Fuse.js, Pagefind, Algolia).
- No search-as-you-navigate keyboard result highlighting beyond Enter-selects-first-result (can
  be added later if it turns out to matter).
- No dedicated `/suche/` page or shareable query-string URL for a search result set.
- No search analytics/tracking of queries.
- No pagination of results (capped at ~20, sorted by relevance).
