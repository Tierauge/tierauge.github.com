# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is the **production site for "Augentierarzt Greifswald"** (Dr. Sabine Sahr, veterinary
ophthalmology, `tieraugen.doctor`) — a real client site, not a demo or example. It's built with
Hugo using the **Celadon** theme, vendored as a standalone copy under `themes/celadon/` (a real
directory copy, not a symlink into the theme's own git checkout elsewhere on disk).

There is no npm/node build step and no test suite — pure Hugo (Go templates + TOML/YAML). The
site is single-language (German, `de-DE`) with no `i18n/` usage — see "Vendored theme
divergence" below for what that implies.

## Common commands

Because the theme is vendored inside `themes/celadon/` and `hugo.toml` sets `theme = "celadon"`,
no `--themesDir`/`--theme` flags are needed (unlike the theme repo's own `exampleSite`):

```bash
hugo server
hugo --minify --destination /tmp/out
```

Deployment: GitHub Pages serves `master:/docs`, so `hugo.toml` sets `publishDir = "docs"` and
`make build` / `make publish` rebuild it (`static/CNAME` and `static/.nojekyll` are copied along).
The site replaced an older Jekyll site; its URLs (`/blog/<Name>.html`, `/blog.html`,
`/story.html`, `/verschiedenes.html`, `/impressum.html`) live on as `aliases:` in front matter —
keep them when renaming or moving content.

A `.hugo_build.lock` file present in the repo root is normal Hugo lock-file litter from a
previous `server`/build run, not something to "fix".

## Vendored theme divergence — read before touching `themes/celadon/`

`themes/celadon/` is **not** kept in sync with the upstream Celadon theme repo. It has been
hand-modified for this site and diverges from upstream in several places. If the upstream theme
is ever updated, these customizations must be manually reapplied — there is no merge/pull
relationship between them.

Known divergences from upstream:

- **`layouts/partials/home/hours.html`, `contact.html`, `map.html`** — three home-section
  layouts that don't exist upstream, built for this site's needs (office hours tables, contact
  cards with phone/address/social links, embedded Google Maps iframes). Upstream only ships
  `hero`, `news`, `cards`, `grid`.
- **`layouts/beitraege/list.html`** — a combined overview page at `/beitraege/` that unions
  articles from `wissensbank`, `patientengeschichten`, and `vortraege` into one listing,
  sidebar-filterable by an explicit `categories` front-matter field (taxonomy defined in
  `data/categories.yaml`) and by `tags`. The three original section list pages
  (`content/wissensbank/_index.md`, `content/patientengeschichten/_index.md`,
  `content/vortraege/_index.md`) are marked with `build: { render: "never" }` so they no longer emit
  `/wissensbank/`, `/patientengeschichten/`, `/vortraege/` pages — only this combined page and
  the individual article URLs (which are unaffected) exist now.
- **`layouts/_default/baseof.html`** — adds a `site.Params.nav.extraLinks` "More" dropdown in
  the nav bar (config in `hugo.toml` under `[params.nav]`), used here to link to sections that
  aren't homepage sections (Beiträge, Impressum).
- **`layouts/_default/list.html` / `single.html`** — UI strings (view toggle labels, "Read →",
  "Back") and date formatting (`02.01.2006`) are **hardcoded in German** directly in the
  template, instead of going through `i18n/` + `{{ T }}` like the upstream theme does. This is
  intentional for a single-language site — don't "fix" it by wiring up i18n unless the site
  becomes multilingual.
- **`layouts/_default/baseof.html`, `assets/css/main.css`, `i18n/*.yaml`** — the nav bar collapses
  into a hamburger menu (`.nav-toggle` / `.nav-menu`, toggled via `#site-nav.nav-collapsed`)
  instead of wrapping or horizontally scrolling the links at a fixed breakpoint. The switch point
  is decided by JS (the last inline `<script>` IIFE in `baseof.html`), which measures whether
  `.nav-links` actually overflows (`scrollWidth` vs `clientWidth`) on load, after web fonts
  settle (`document.fonts.ready`), and on resize — not a hardcoded `@media` width — because 7
  primary links + "Mehr" + CTA + theme toggle stop fitting at a width that depends on rendered
  text, not a round number. If you add/remove nav links, this keeps working automatically; don't
  reintroduce a fixed breakpoint for it. Added `nav_toggle_aria` to all three `i18n/*.yaml` files
  for the hamburger button's aria-label, following the existing `theme_toggle_aria` pattern.
- **`hugo.toml`, `layouts/index.json.json`, `layouts/_partials/components/search.html`,
  `layouts/_default/baseof.html`, `i18n/*.yaml`** — site-wide search. `hugo.toml` enables Hugo's
  built-in `JSON` output format on the home page (`[outputs] home = ["HTML", "JSON"]`);
  `layouts/index.json.json` renders that as `/index.json`, a flat array of every reachable page
  (`Kind` `page`/`home`/`section`, minus the three `render: never` section indexes and
  taxonomy/term pages) with `title`, `url`, `image` (empty string if the page has no
  `image`/`thumbnail` param — no placeholder fallback, unlike `wissen/list.html`'s cards), a
  description/summary, and the full (untruncated) plain-text body for matching. The nav bar's
  `#nav-search-toggle` icon button is a **sibling** of `.nav-menu`, not a child of it, so it
  stays visible in both the expanded and hamburger-collapsed nav states. `components/search.html`
  (included once from `baseof.html`, alongside `mobile-action-bar.html`) renders a native
  `<dialog>` that lazy-`fetch()`es `/index.json` on first open only and does all matching/scoring/
  snippet-highlighting client-side in vanilla JS — no external search library (Fuse.js, Pagefind,
  etc.), since the index is small (~50 short pages). New i18n keys (`search_aria`,
  `search_placeholder`, `search_no_results`, `search_close_aria`) were added to all three
  `i18n/*.yaml` files, following the existing `nav_toggle_aria` pattern, rather than the
  hardcoded-German convention used specifically in `list.html`/`single.html`.
- **`assets/css/main.css`** — a few mobile-only fixes layered on top of the upstream styles,
  tuned for this site's actual content (not generic upstream behavior):
  - `#scroll-top` has a themed border — it and `.mobile-action-bar` both use
    `var(--color-primary)` as background, so without a border the button visually blends into
    the bar — and sits above `.mobile-action-bar`'s real height (~72px, not the 64px the layout
    originally assumed) plus `env(safe-area-inset-bottom)`.
  - `.hero-media--circle`'s decorative iris ring (`--iris-size`, set inline per-call in
    `layouts/_partials/motifs/iris-circle.html`) is fixed at `240px`, sized for the desktop
    `190px` circle. On mobile (`≤960px`) it's overridden with `!important` to
    `calc(100% + 24px)` so the ring scales with the enlarged `220px` mobile circle instead of
    bleeding up into the hero's top padding.
  - `.hero`'s bottom padding on mobile adds `56px` (the wave's rendered height) to clear the
    absolutely-positioned `.wave-motif--fill`, which doesn't reserve space in normal flow and
    otherwise overlaps `.hero-links` at narrow widths.

## Architecture

### Homepage sections (`hugo.toml`)

`params.homepage.sections = ["about", "sprechzeiten", "kontakt", "anfahrt"]`, each mapped to a
custom `layout`:

| section       | layout    | data file            |
|---------------|-----------|----------------------|
| `about`       | `hero`    | `data/profile.yaml`  |
| `sprechzeiten`| `hours`   | `data/sprechzeiten.yaml` |
| `kontakt`     | `contact` | `data/kontakt.yaml`  |
| `anfahrt`     | `map`     | `data/anfahrt.yaml`  |

All `data/*.yaml` files are flat (no `data/<lang>/` folder) since this is single-language —
they're picked up by the theme's third-tier fallback (see the theme's own CLAUDE.md for the
3-tier resolution logic).

### Content sections (`content/`)

Three Markdown sections beyond the homepage — `wissensbank`, `vortraege`, and `patientengeschichten` —
all have their individual list pages disabled (via `build: { render: "never" }` in their `_index.md`).
Instead, all three sections are combined into a single `/beitraege/` overview page (see
"Vendored theme divergence" above for details on the combined layout):

- `wissensbank/` — knowledge base articles on eye conditions. Listed on `/beitraege/`.
- `vortraege/` — talks, posters, publications. Listed on `/beitraege/`.
- `patientengeschichten/` — patient case stories. Listed on `/beitraege/`.
- `impressum.md` — standalone legal notice page (German `§ 5 TMG` requirement), linked only via
  the nav "More" dropdown, not a homepage section.

Individual pages in these sections use the theme's standard `cascade`-applied `single` layout
(set in `hugo.toml`'s `[[cascade]]` block).
