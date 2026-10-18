# Beiträge-Übersichtsseite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a new `/beitraege/` page that lists articles from `wissensbank`, `patientengeschichten`, and `vortraege` together, filterable by an explicit `categories` front-matter field and by `tags`, replacing the three separate section list pages.

**Architecture:** A new Hugo section `content/beitraege/` with a custom `beitraege` layout renders a two-column page (category/tag sidebar + article grid), sourcing articles via a union query over the three existing content folders and filtering client-side on `data-categories`/`data-tags` attributes. `data/categories.yaml` is the category taxonomy; each article gets an explicit `categories: [...]` front-matter field (independent of which folder it lives in). The three old section `_index.md` pages stop rendering.

**Tech Stack:** Hugo (Go templates, TOML/YAML front matter), vanilla CSS + inline vanilla JS (matching the existing `wissensbank/list.html` pattern) — no build step, no test framework.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-19-beitraege-overview-design.md` — every decision below traces back to it.
- This repo has **no test suite** (per `site-tierauge/CLAUDE.md`). "Testing" a step means: run `hugo --minify --destination /tmp/out-beitraege` from the repo root and confirm **zero warnings**, then `grep`/inspect the generated HTML in `/tmp/out-beitraege` for the expected markup. Every step that would normally be a unit test is written as a build+grep check instead.
- Working directory for all commands is the repo root: `/home/andre/Downloads/hugo-celadon-main/site-tierauge`.
- No `--themesDir`/`--theme` flags needed — `themes/celadon/` is vendored locally and `hugo.toml` already sets `theme = "celadon"`.
- Commit after every task (not every step) — each task is one reviewable unit.
- `categories` and `tags` front matter are arrays, matching existing `tags: [...]` style exactly (double-quoted strings, comma-space separated, single line).

---

### Task 1: Category taxonomy data file

**Files:**
- Create: `data/categories.yaml`

**Interfaces:**
- Produces: a top-level YAML list, each entry `{key, label, description}`, consumed by Task 6's template as `hugo.Data.categories` and by Task 3/4's front-matter values (`categories: ["<key>"]` must match one of these keys).

- [ ] **Step 1: Create the data file**

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

- [ ] **Step 2: Verify the data file parses**

Run: `hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20`
Expected: zero warnings, zero errors — `data/categories.yaml` isn't referenced by any template yet (that happens in Task 6), so this build should be identical to the pre-change baseline, just confirming the YAML itself is well-formed.

- [ ] **Step 3: Commit**

```bash
git add data/categories.yaml
git commit -m "$(cat <<'EOF'
Add category taxonomy data file for Beiträge overview

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Retire the old section list pages

**Files:**
- Modify: `content/wissensbank/_index.md`
- Modify: `content/patientengeschichten/_index.md`
- Modify: `content/vortraege/_index.md`

**Interfaces:**
- Consumes: nothing from prior tasks.
- Produces: the three sections stop emitting `/wissensbank/`, `/patientengeschichten/`, `/vortraege/` list pages, while `site.RegularPages "Section" "<name>"` (used by Task 6) still returns their child articles.

- [ ] **Step 1: Add `_build.render: never` to each section index**

`content/wissensbank/_index.md` — current content:

```yaml
---
title: "Wissensbank"
layout: "list"
---

Interessante Informationen über gängige Augenerkrankungen von Hunden, Katzen und Heimtieren.
```

New content:

```yaml
---
title: "Wissensbank"
layout: "list"
_build:
  render: "never"
---

Interessante Informationen über gängige Augenerkrankungen von Hunden, Katzen und Heimtieren.
```

`content/patientengeschichten/_index.md` — current content:

```yaml
---
title: "Patientengeschichten"
layout: "list"
---

Ausgewählte Fallberichte aus der augentierärztlichen Praxis.
```

New content:

```yaml
---
title: "Patientengeschichten"
layout: "list"
_build:
  render: "never"
---

Ausgewählte Fallberichte aus der augentierärztlichen Praxis.
```

`content/vortraege/_index.md` — current content:

```yaml
---
title: "Vorträge, Poster, Publikationen"
layout: "list"
---

Vorträge, Poster und Publikationen aus Fortbildungen und Fachtagungen.
```

New content:

```yaml
---
title: "Vorträge, Poster, Publikationen"
layout: "list"
_build:
  render: "never"
---

Vorträge, Poster und Publikationen aus Fortbildungen und Fachtagungen.
```

- [ ] **Step 2: Build and verify the old list pages are gone but articles remain**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20
ls /tmp/out-beitraege/wissensbank/ 2>/dev/null
ls /tmp/out-beitraege/wissensbank/glaukom/ 2>/dev/null
```
Expected: `ls /tmp/out-beitraege/wissensbank/` still lists per-article subdirectories (e.g. `glaukom/`) but there is **no** `/tmp/out-beitraege/wissensbank/index.html`; `ls .../glaukom/` shows `index.html` (the article itself still renders fine).

- [ ] **Step 3: Commit**

```bash
git add content/wissensbank/_index.md content/patientengeschichten/_index.md content/vortraege/_index.md
git commit -m "$(cat <<'EOF'
Stop rendering the three old section list pages

They're replaced by the new combined /beitraege/ overview; child
articles keep rendering at their existing URLs.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Add `categories` front matter to all existing articles

**Files:**
- Modify: all 20 files in `content/wissensbank/*.md` (except `_index.md`)
- Modify: both files in `content/patientengeschichten/*.md` (except `_index.md`)
- Modify: all 8 files in `content/vortraege/*.md` (except `_index.md`)

**Interfaces:**
- Consumes: category keys from Task 1's `data/categories.yaml` (`wissensbank`, `patientengeschichten`, `vortraege`).
- Produces: every article has `categories: ["<matching-key>"]`, consumed by Task 6's template for filtering and the category badge.

- [ ] **Step 1: Insert `categories` after the `date:` line in every article**

All articles in each of the three folders currently have `date:` as their second front-matter line (confirmed by inspection). Run from the repo root:

```bash
for f in content/wissensbank/*.md; do
  [ "$(basename "$f")" = "_index.md" ] && continue
  grep -q '^categories:' "$f" || sed -i '/^date:/a categories: ["wissensbank"]' "$f"
done

for f in content/patientengeschichten/*.md; do
  [ "$(basename "$f")" = "_index.md" ] && continue
  grep -q '^categories:' "$f" || sed -i '/^date:/a categories: ["patientengeschichten"]' "$f"
done

for f in content/vortraege/*.md; do
  [ "$(basename "$f")" = "_index.md" ] && continue
  grep -q '^categories:' "$f" || sed -i '/^date:/a categories: ["vortraege"]' "$f"
done
```

- [ ] **Step 2: Verify every article got a `categories` line**

Run:
```bash
grep -L '^categories:' content/wissensbank/*.md content/patientengeschichten/*.md content/vortraege/*.md | grep -v _index.md
```
Expected: no output (every non-`_index.md` file now has `categories:`).

Run:
```bash
grep -c '^categories:' content/wissensbank/*.md content/patientengeschichten/*.md content/vortraege/*.md | grep -v ':0' | grep -v _index.md | wc -l
```
Expected: `30` (20 wissensbank + 2 patientengeschichten + 8 vortraege).

- [ ] **Step 3: Spot-check one file per folder**

Run: `head -6 content/wissensbank/glaukom.md content/patientengeschichten/abby.md content/vortraege/fortbildung.md`
Expected: each shows `categories: ["wissensbank"]`, `categories: ["patientengeschichten"]`, `categories: ["vortraege"]` respectively, directly after the `date:` line.

- [ ] **Step 4: Commit**

```bash
git add content/wissensbank content/patientengeschichten content/vortraege
git commit -m "$(cat <<'EOF'
Add explicit categories front matter to all articles

Category is now declared per-article (matching current section),
decoupled from folder structure, per the Beiträge overview design.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Back-fill missing `tags` front matter

**Files:**
- Modify: 19 files in `content/wissensbank/*.md` (all except `augenuntersuchung.md`, which already has tags)
- Modify: both files in `content/patientengeschichten/*.md`

**Interfaces:**
- Consumes: nothing from prior tasks (tags are freeform, same mechanism as the 8 `vortraege` articles that already carry them).
- Produces: every article now has `tags: [...]`, consumed by Task 6's template for the tag cloud and per-card tag row.

Proposed tags below were drafted by reading each article's diagnosis/species/procedure content, matching the Title-Case German style already used (e.g. `["Untersuchung", "Sehtest", "Spaltlampe"]` on `augenuntersuchung.md`, `["Fortbildung"]` on the `vortraege` articles). **These are visible here for review before this task runs** — edit the `sed` commands below if any tag should change.

- [ ] **Step 1: Insert `tags` after the `categories:` line for each article**

Run from the repo root:

```bash
sed -i '/^categories:/a tags: ["Glaukom", "Augeninnendruck", "Notfall"]' content/wissensbank/glaukom.md
sed -i '/^categories:/a tags: ["Bluthochdruck", "Netzhaut", "Katze"]' content/wissensbank/bluthochdruck.md
sed -i '/^categories:/a tags: ["Dermoid", "Hornhaut", "Fehlbildung"]' content/wissensbank/dermoid.md
sed -i '/^categories:/a tags: ["Endotheldystrophie", "Hornhaut", "Hund"]' content/wissensbank/endotheldystrophie.md
sed -i '/^categories:/a tags: ["Herpesvirus", "Konjunktivitis", "Katze"]' content/wissensbank/herpeskeratitis-und-konjunktivitis.md
sed -i '/^categories:/a tags: ["Horner-Syndrom", "Nervenerkrankung"]' content/wissensbank/horner-syndrom.md
sed -i '/^categories:/a tags: ["Irisatrophie", "Alterserscheinung", "Hund"]' content/wissensbank/irisatrophie.md
sed -i '/^categories:/a tags: ["Irismelanom", "Tumor", "Katze"]' content/wissensbank/irismelanom.md
sed -i '/^categories:/a tags: ["Katarakt", "Grauer Star", "Hund"]' content/wissensbank/katarakt.md
sed -i '/^categories:/a tags: ["Konjunktivitis", "Junghund"]' content/wissensbank/konjunctivitis-follicularis.md
sed -i '/^categories:/a tags: ["Konjunktivitis", "Allergie", "Hund"]' content/wissensbank/konjunktivitis.md
sed -i '/^categories:/a tags: ["KSC", "Hornhaut", "Schäferhund"]' content/wissensbank/ksc.md
sed -i '/^categories:/a tags: ["Lidrandtumor", "Tumor", "OP"]' content/wissensbank/lidrandtumor.md
sed -i '/^categories:/a tags: ["Melting Ulcer", "Notfall", "Hornhaut"]' content/wissensbank/melting-ulcer.md
sed -i '/^categories:/a tags: ["Brachyzephalensyndrom", "Mops", "Trockenes Auge"]' content/wissensbank/mops.md
sed -i '/^categories:/a tags: ["Nukleussklerose", "Alterserscheinung", "Linse"]' content/wissensbank/nukleussklerose.md
sed -i '/^categories:/a tags: ["Ophthalmoplegie", "Nervenerkrankung"]' content/wissensbank/ophthalmoplegie.md
sed -i '/^categories:/a tags: ["SCCED", "Hornhaut", "Hund"]' content/wissensbank/scced.md
sed -i '/^categories:/a tags: ["Uveitis", "Regenbogenhautentzündung", "Notfall"]' content/wissensbank/uveitis.md

sed -i '/^categories:/a tags: ["Cornea Nigra", "Hornhaut", "Katze"]' content/patientengeschichten/abby.md
sed -i '/^categories:/a tags: ["Ektope Zilie", "Hornhautulcus", "Hund"]' content/patientengeschichten/maja.md
```

- [ ] **Step 2: Verify every article now has tags**

Run:
```bash
grep -L '^tags:' content/wissensbank/*.md content/patientengeschichten/*.md content/vortraege/*.md | grep -v _index.md
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add content/wissensbank content/patientengeschichten
git commit -m "$(cat <<'EOF'
Back-fill tags on wissensbank and patientengeschichten articles

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: New `beitraege` content section

**Files:**
- Create: `content/beitraege/_index.md`

**Interfaces:**
- Produces: a page at `/beitraege/` using `layout: "beitraege"`, which Task 6 implements.

- [ ] **Step 1: Create the section index**

```yaml
---
title: "Beiträge"
layout: "beitraege"
---

Alle Wissensbank-Artikel, Patientengeschichten und Vorträge, Poster und Publikationen an einem Ort.
```

- [ ] **Step 2: Build and confirm the page exists (content only, no template yet)**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20
```
Expected: zero warnings, zero errors. Hugo falls back to `_default/list.html` since the `beitraege` layout doesn't exist yet — the page renders without the sidebar/grid. That's expected at this checkpoint and resolved by Task 6; don't fix it here.

- [ ] **Step 3: Commit**

```bash
git add content/beitraege/_index.md
git commit -m "$(cat <<'EOF'
Add content/beitraege section index

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: `beitraege` list template (sidebar + grid + filtering)

**Files:**
- Create: `themes/celadon/layouts/beitraege/list.html`

**Interfaces:**
- Consumes: `hugo.Data.categories` (Task 1: list of `{key, label, description}`), `.Params.categories` / `.Params.tags` on each article (Tasks 3–4), `content/beitraege/_index.md` (Task 5).
- Produces: the rendered `/beitraege/` page — verified by Task 11's full build.

- [ ] **Step 1: Write the template**

```go-html-template
{{ define "main" }}
  <section class="listing-shell beitraege-shell">
    <div class="listing-header">
      <h1 class="article-title">{{ .Title }}</h1>
      <div class="listing-description markdown-body">
        {{ .Content }}
      </div>
    </div>

    {{ $pages := (where site.RegularPages "Section" "wissensbank") |
        union (where site.RegularPages "Section" "patientengeschichten") |
        union (where site.RegularPages "Section" "vortraege") }}
    {{ $pages = $pages.ByDate.Reverse }}

    {{ $categories := hugo.Data.categories }}

    {{ $catLabels := dict }}
    {{ range $categories }}
      {{ $catLabels = merge $catLabels (dict .key .label) }}
    {{ end }}

    {{ $catCounts := dict }}
    {{ range $pages }}
      {{ range .Params.categories }}
        {{ $current := index $catCounts . | default 0 }}
        {{ $catCounts = merge $catCounts (dict . (add $current 1)) }}
      {{ end }}
    {{ end }}

    {{ $allTags := slice }}
    {{ range $pages }}
      {{ with .Params.tags }}
        {{ $allTags = $allTags | append . }}
      {{ end }}
    {{ end }}
    {{ $uniqueTags := $allTags | uniq | sort }}

    <div class="beitraege-layout">
      <aside class="beitraege-sidebar">
        <div class="sidebar-block">
          <h2 class="sidebar-title">Kategorien</h2>
          <ul class="category-list">
            <li>
              <button class="filter-btn active" data-category-filter="all">
                <span>Alle</span> <span class="count">{{ len $pages }}</span>
              </button>
            </li>
            {{ range $categories }}
              <li>
                <button class="filter-btn" data-category-filter="{{ .key }}">
                  <span>{{ .label }}</span> <span class="count">{{ index $catCounts .key | default 0 }}</span>
                </button>
              </li>
            {{ end }}
          </ul>
        </div>

        <div class="sidebar-block">
          <h2 class="sidebar-title">Tags</h2>
          <div class="tag-cloud">
            <button class="filter-btn active" data-tag-filter="all">Alle</button>
            {{ range $uniqueTags }}
              <button class="filter-btn" data-tag-filter="{{ . | lower }}">{{ . }}</button>
            {{ end }}
          </div>
        </div>
      </aside>

      <div class="beitraege-main">
        <div class="listing-toolbar" role="group" aria-label="Ansicht wählen">
          <button type="button" class="view-btn" data-view="view-card" aria-label="Kartenansicht">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect></svg>
          </button>
          <button type="button" class="view-btn" data-view="view-list" aria-label="Listenansicht">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><circle cx="4" cy="6" r="1"></circle><circle cx="4" cy="12" r="1"></circle><circle cx="4" cy="18" r="1"></circle></svg>
          </button>
          <button type="button" class="view-btn" data-view="view-compact" aria-label="Kompaktansicht">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="5" height="5"></rect><rect x="10" y="4" width="5" height="5"></rect><rect x="17" y="4" width="4" height="5"></rect><rect x="3" y="11" width="4" height="5"></rect><rect x="9" y="11" width="4" height="5"></rect><rect x="15" y="11" width="6" height="5"></rect></svg>
          </button>
        </div>

        <div id="listing-container" class="listing-grid view-card">
          {{ range $pages }}
            {{ $thumb := or .Params.thumbnail .Params.image "/images/profile.jpg" }}
            {{ $thumbPath := strings.TrimPrefix "/" $thumb }}
            {{ $tags := .Params.tags | default (slice) }}
            {{ $cats := .Params.categories | default (slice) }}
            <article class="listing-card"
              data-tags="{{ range $i, $tag := $tags }}{{ if $i }},{{ end }}{{ lower $tag }}{{ end }}"
              data-categories="{{ range $i, $cat := $cats }}{{ if $i }},{{ end }}{{ lower $cat }}{{ end }}">
              <div class="listing-thumb">
                <a href="{{ .RelPermalink }}">
                  <img src="{{ $thumbPath | relURL }}" alt="{{ .Title }}" loading="lazy">
                </a>
              </div>

              <div class="card-body">
                <div class="listing-date">{{ .Date.Format "02.01.2006" }}</div>

                {{ range $cats }}
                  {{ with index $catLabels . }}
                    <span class="category-badge">{{ . }}</span>
                  {{ end }}
                {{ end }}

                <h3><a href="{{ .RelPermalink }}">{{ .Title }}</a></h3>

                {{ with .Plain }}
                  <p class="summary">{{ . | truncate 120 }}</p>
                {{ end }}

                {{ with .Params.tags }}
                <div class="tag-row">
                  {{ range . }}
                    <span class="tag">#{{ . }}</span>
                  {{ end }}
                </div>
                {{ end }}
              </div>

              <a href="{{ .RelPermalink }}" class="read-more-btn">Weiterlesen →</a>
            </article>
          {{ end }}
        </div>
      </div>
    </div>
  </section>

  <script>
    (function () {
      const container = document.getElementById("listing-container");
      if (!container) return;
      const viewButtons = document.querySelectorAll(".view-btn");
      const categoryButtons = document.querySelectorAll("[data-category-filter]");
      const tagButtons = document.querySelectorAll("[data-tag-filter]");
      const cards = container.querySelectorAll(".listing-card");
      const storageKey = "listing-view-mode";

      const applyView = (mode) => {
        container.classList.remove("view-card", "view-list", "view-compact");
        container.classList.add(mode);
        viewButtons.forEach((btn) =>
          btn.classList.toggle("active", btn.dataset.view === mode)
        );
      };

      const storedView = localStorage.getItem(storageKey) || "view-card";
      applyView(storedView);

      viewButtons.forEach((btn) =>
        btn.addEventListener("click", () => {
          const mode = btn.dataset.view;
          applyView(mode);
          localStorage.setItem(storageKey, mode);
        })
      );

      let activeCategory = "all";
      let activeTag = "all";

      const applyFilters = () => {
        cards.forEach((card) => {
          const cats = card.dataset.categories ? card.dataset.categories.split(",") : [];
          const tags = card.dataset.tags ? card.dataset.tags.split(",") : [];
          const matchesCategory = activeCategory === "all" || cats.includes(activeCategory);
          const matchesTag = activeTag === "all" || tags.includes(activeTag);
          card.classList.toggle("hidden", !(matchesCategory && matchesTag));
        });
      };

      categoryButtons.forEach((btn) =>
        btn.addEventListener("click", () => {
          activeCategory = btn.dataset.categoryFilter;
          categoryButtons.forEach((b) => b.classList.toggle("active", b === btn));
          applyFilters();
        })
      );

      tagButtons.forEach((btn) =>
        btn.addEventListener("click", () => {
          activeTag = btn.dataset.tagFilter;
          tagButtons.forEach((b) => b.classList.toggle("active", b === btn));
          applyFilters();
        })
      );

      applyFilters();
    })();
  </script>
{{ end }}
```

- [ ] **Step 2: Build and verify the page renders with all three sections combined**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -30
```
Expected: zero warnings, zero errors.

Run:
```bash
grep -c 'listing-card' /tmp/out-beitraege/beitraege/index.html
grep -o 'data-category-filter="[a-z]*"' /tmp/out-beitraege/beitraege/index.html | sort -u
grep -c 'category-badge' /tmp/out-beitraege/beitraege/index.html
```
Expected: `listing-card` count is 30 × 2 (each card's opening tag appears once per `<article class="listing-card"` — just confirm the count is non-zero and roughly matches 30 articles); `data-category-filter` values are `all`, `patientengeschichten`, `vortraege`, `wissensbank`; `category-badge` count is non-zero.

- [ ] **Step 3: Commit**

```bash
git add themes/celadon/layouts/beitraege/list.html
git commit -m "$(cat <<'EOF'
Add beitraege list template with category/tag sidebar filtering

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 7: Sidebar and category badge CSS

**Files:**
- Modify: `themes/celadon/assets/css/main.css`

**Interfaces:**
- Consumes: class names from Task 6's template (`beitraege-layout`, `beitraege-sidebar`, `sidebar-block`, `sidebar-title`, `category-list`, `tag-cloud`, `category-badge`), reuses existing `.filter-btn`, `.listing-grid`, `.listing-card`, `.tag`, `.tag-row`, `.view-btn` unchanged.
- Produces: visually distinct two-column layout, collapsing to stacked below 960px (matching the existing breakpoint used elsewhere in this file).

- [ ] **Step 1: Append the new rules**

Add at the end of `themes/celadon/assets/css/main.css`:

```css
/* Beiträge overview: category/tag sidebar + category badges */
.beitraege-layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 2rem;
  align-items: start;
}

.beitraege-sidebar {
  display: flex;
  flex-direction: column;
  gap: 1.75rem;
  position: sticky;
  top: 1.5rem;
}

.sidebar-title {
  font-size: 0.95rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--color-secondary);
  margin: 0 0 0.75rem;
}

.category-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.beitraege-sidebar .filter-btn {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.5rem;
  text-align: left;
  border-radius: 10px;
}

.tag-cloud .filter-btn {
  width: auto;
}

.beitraege-sidebar .filter-btn .count {
  font-size: 0.75em;
  opacity: 0.75;
}

.category-badge {
  display: inline-block;
  align-self: flex-start;
  background: var(--color-primary);
  color: var(--color-bg);
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 0.15rem 0.6rem;
  border-radius: 999px;
}

@media (max-width: 960px) {
  .beitraege-layout {
    grid-template-columns: 1fr;
  }

  .beitraege-sidebar {
    position: static;
    flex-direction: row;
    flex-wrap: wrap;
  }

  .category-list {
    flex-direction: row;
    flex-wrap: wrap;
  }

  .beitraege-sidebar .filter-btn {
    width: auto;
  }
}
```

- [ ] **Step 2: Build and visually spot-check**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20
```
Expected: zero warnings/errors. Then run `hugo server` and open `http://localhost:1313/beitraege/` in a browser — confirm the sidebar sits to the left of the grid on a wide viewport, stacks above it below ~960px width, and clicking a category or tag button visually hides non-matching cards.

- [ ] **Step 3: Commit**

```bash
git add themes/celadon/assets/css/main.css
git commit -m "$(cat <<'EOF'
Add sidebar and category badge styles for Beiträge overview

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 8: Delete the superseded wissensbank list template

**Files:**
- Delete: `themes/celadon/layouts/wissensbank/list.html`

**Interfaces:**
- Consumes: nothing (this template is no longer reachable — `content/wissensbank/_index.md` has `_build.render: never` since Task 2, so Hugo never invokes it).
- Produces: n/a (removal).

- [ ] **Step 1: Delete the file**

```bash
rm themes/celadon/layouts/wissensbank/list.html
rmdir themes/celadon/layouts/wissensbank 2>/dev/null || true
```

- [ ] **Step 2: Build and verify no regressions**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20
```
Expected: zero warnings, zero errors (confirms nothing else referenced this template).

- [ ] **Step 3: Commit**

```bash
git add -A themes/celadon/layouts/wissensbank
git commit -m "$(cat <<'EOF'
Remove superseded wissensbank list template

Superseded by themes/celadon/layouts/beitraege/list.html.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 9: Update navigation

**Files:**
- Modify: `hugo.toml`

**Interfaces:**
- Consumes: nothing.
- Produces: nav "Mehr" dropdown shows "Beiträge" + "Impressum" instead of the three old links.

- [ ] **Step 1: Replace the extraLinks block**

Current (`hugo.toml`, end of file):

```toml
[params.nav]
  moreLabel = "Mehr"

  [[params.nav.extraLinks]]
    title = "Wissensbank"
    url = "/wissensbank/"

  [[params.nav.extraLinks]]
    title = "Patientengeschichten"
    url = "/patientengeschichten/"

  [[params.nav.extraLinks]]
    title = "Vorträge, Poster, Publikationen"
    url = "/vortraege/"

  [[params.nav.extraLinks]]
    title = "Impressum"
    url = "/impressum/"
```

New:

```toml
[params.nav]
  moreLabel = "Mehr"

  [[params.nav.extraLinks]]
    title = "Beiträge"
    url = "/beitraege/"

  [[params.nav.extraLinks]]
    title = "Impressum"
    url = "/impressum/"
```

- [ ] **Step 2: Build and verify the nav markup**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tail -20
grep -o 'href="/beitraege/"' /tmp/out-beitraege/index.html | head -1
grep -c 'href="/wissensbank/"' /tmp/out-beitraege/index.html
```
Expected: zero warnings; the `/beitraege/` link is present in the nav; `href="/wissensbank/"` count is `0` (no more direct link to the retired list page — individual article links like `/wissensbank/glaukom/` are unaffected since they're a different href).

- [ ] **Step 3: Commit**

```bash
git add hugo.toml
git commit -m "$(cat <<'EOF'
Point nav "Mehr" dropdown at the new Beiträge overview

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 10: Update site documentation

**Files:**
- Modify: `site-tierauge/CLAUDE.md`

**Interfaces:**
- Consumes: nothing (documentation only).
- Produces: accurate description of the vendored theme divergence for future readers.

- [ ] **Step 1: Update the "Vendored theme divergence" section**

In `site-tierauge/CLAUDE.md`, find this bullet:

```
- **`layouts/partials/home/hours.html`, `contact.html`, `map.html`** — three home-section
  layouts that don't exist upstream, built for this site's needs (office hours tables, contact
  cards with phone/address/social links, embedded Google Maps iframes). Upstream only ships
  `hero`, `news`, `cards`, `grid`.
```

Leave it as-is, and immediately after it insert a new bullet:

```
- **`layouts/beitraege/list.html`** — a combined overview page at `/beitraege/` that unions
  articles from `wissensbank`, `patientengeschichten`, and `vortraege` into one listing,
  sidebar-filterable by an explicit `categories` front-matter field (taxonomy defined in
  `data/categories.yaml`) and by `tags`. The three original section list pages
  (`content/wissensbank/_index.md`, `content/patientengeschichten/_index.md`,
  `content/vortraege/_index.md`) are marked `_build.render: never` so they no longer emit
  `/wissensbank/`, `/patientengeschichten/`, `/vortraege/` pages — only this combined page and
  the individual article URLs (which are unaffected) exist now.
```

Then find the "Content sections" table/description further down that says:

```
- `wissensbank/` — knowledge base articles on eye conditions (tagged, filterable, combined with
  `vortraege` in its listing).
```

Replace with:

```
- `wissensbank/` — knowledge base articles on eye conditions. Listed (along with
  `patientengeschichten` and `vortraege`) on the combined `/beitraege/` overview page, not on
  its own list page (see "Vendored theme divergence" above).
```

And find:

```
- `vortraege/` — talks, posters, publications.
- `patientengeschichten/` — patient case stories.
```

Replace with:

```
- `vortraege/` — talks, posters, publications. Listed on `/beitraege/`, not its own list page.
- `patientengeschichten/` — patient case stories. Listed on `/beitraege/`, not its own list page.
```

- [ ] **Step 2: Verify the doc renders sensibly**

Run: `grep -c 'beitraege' site-tierauge/CLAUDE.md` (or `grep -c 'beitraege' CLAUDE.md` if already at repo root)
Expected: non-zero — confirms the new bullet was actually inserted.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "$(cat <<'EOF'
Document the new Beiträge overview in the vendored theme divergence list

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 11: Full-site verification

**Files:**
- None (verification only).

**Interfaces:**
- Consumes: everything from Tasks 1–10.
- Produces: confidence the whole site builds clean and the feature works end-to-end.

- [ ] **Step 1: Full clean build**

Run:
```bash
rm -rf /tmp/out-beitraege
hugo --minify --destination /tmp/out-beitraege 2>&1 | tee /tmp/hugo-build.log
grep -i 'warn\|error' /tmp/hugo-build.log
```
Expected: the grep finds nothing (no WARN or ERROR lines) — a clean build per this repo's stated bar.

- [ ] **Step 2: Confirm old URLs are gone, new URL and article URLs work**

Run:
```bash
test -f /tmp/out-beitraege/wissensbank/index.html && echo "FAIL: old wissensbank list still renders" || echo "OK: gone"
test -f /tmp/out-beitraege/patientengeschichten/index.html && echo "FAIL: old patientengeschichten list still renders" || echo "OK: gone"
test -f /tmp/out-beitraege/vortraege/index.html && echo "FAIL: old vortraege list still renders" || echo "OK: gone"
test -f /tmp/out-beitraege/beitraege/index.html && echo "OK: /beitraege/ renders" || echo "FAIL: /beitraege/ missing"
test -f /tmp/out-beitraege/wissensbank/glaukom/index.html && echo "OK: article URL unaffected" || echo "FAIL: article URL broken"
```
Expected: all five lines print `OK: ...`.

- [ ] **Step 3: Manual smoke test in the browser**

Run: `hugo server` (from repo root), open `http://localhost:1313/beitraege/`:
- Confirm cards from all three former sections appear together, each with a category badge.
- Click each category filter button — confirm the count matches the number of visible cards and non-matching cards hide.
- Click "Alle" to reset, then click a tag — confirm it narrows further and combines correctly with an active category filter.
- Toggle card/list/compact view — confirm it still works and persists across a page reload (localStorage).
- Click through to one article from each former section — confirm the article page itself renders normally.
- Check the nav "Mehr" dropdown shows "Beiträge" and "Impressum" only.

Expected: all of the above behave as described, no console errors in the browser devtools.

- [ ] **Step 4: Stop the dev server**

Press `Ctrl+C` in the terminal running `hugo server`.

No commit for this task — it's verification only, not a code change.

---

## Notes for the implementer

- Tasks 3 and 4 modify the same files in two passes (categories first, then tags) so each commit is a focused, reviewable diff. Don't combine them.
- If any proposed tag in Task 4 looks wrong on review, edit that one `sed` line before running the block — don't hand-edit the resulting files afterward, keep the script as the source of truth for that task.
- Task 8's directory removal (`rmdir ... || true`) is safe even if the directory doesn't exist or still has other files in it (the `|| true` swallows the "directory not empty"/"no such file" error either way, and `git add -A` in the same task's commit step is what actually stages the deletion).
