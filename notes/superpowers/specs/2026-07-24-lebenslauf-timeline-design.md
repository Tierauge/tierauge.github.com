# Lebenslauf-Timeline auf /ueber-mich/

## Ziel

Die Seite "Über mich" ([content/ueber-mich.md](../../../content/ueber-mich.md)) bekommt eine
vertikale Timeline-Komponente für den beruflichen Werdegang, im Stil von
https://edu-sharing-network.org/projekt-hackathoern/#Timeline (zentrale Linie, Punkt-Marker,
abwechselnd links/rechts angeordnete Einträge), aber mit den Farben und der Typografie dieser
Seite statt der Referenzfarben (Schwarz/Oliv-Grün).

Die bisherigen Abschnitte "## Qualifikation" und "## Berufliche Stationen" (zwei separate
Markdown-Listen) werden zu einer gemeinsamen, chronologisch sortierten Timeline
zusammengeführt.

## Abweichung vom Referenzdesign

Die Referenzseite trennt Datum und Titel/Text in zwei gegenüberliegende Spalten links/rechts der
Mittellinie – das setzt eine breite Seite (~1400px) voraus. Der Artikeltext dieser Seite ist auf
900px Lesebreite begrenzt (`.article-content`, `.markdown-body` in
[main.css:1199-1205](../../../themes/celadon/assets/css/main.css#L1199-L1205)).

Deshalb: Datum, Titel und Text bilden **einen Block pro Eintrag**, der abwechselnd links/rechts
der Mittellinie sitzt (Punkt-Marker auf der Linie, kurzer Verbindungsstrich zum Block), statt
Datum und Titel in getrennte Spalten zu splitten.

## Daten (`data/lebenslauf.yaml`, neu)

Flache Liste (kein `data/<lang>/`, da einsprachige Seite), ein Eintrag pro Timeline-Punkt, Feld
`text` ist Markdown-fähig (läuft durch `enrich-text.html`, unterstützt `==highlight==` und
`~~accent~~` sowie normale Markdown-Links).

Quelle: `Lebenslauf.pdf` (vom Seiteninhaber eingefügt). Nur fachlich/beruflich relevante
Stationen ab dem Studium – Schulzeit und Bankkauffrau-Ausbildung bewusst ausgelassen (auf
Wunsch). Persönliche Daten aus dem Original-Lebenslauf (Geburtsdatum, Privatadresse, Telefon,
private E-Mail, Familienstand) werden **nicht** übernommen – nicht für eine öffentliche
Praxis-Website bestimmt.

1. **10/2002–02/2008** – Studium der Veterinärmedizin, Universität Leipzig
2. **03/2008–07/2012** – Klinik für Kleintiere der Universität Leipzig
3. **03/2008–02/2014** – Dissertation (summa cum laude)
4. **01/2011** – Zusatzbezeichnung Augenheilkunde
5. **09/2012–08/2018** – Augen-Tierarztpraxis Dr. I. Allgoewer, Berlin
6. **03/2015** – FVO-Förderpreis (für die Dissertation)
7. **12/2015** – Mitglied im [Dortmunder Kreis (DOK)](https://www.dok-vet.de)
8. **04/2019–03/2021** – Anicura Tierklinik Potsdam, Augenheilkunde
9. **seit 04/2021** – Tierärztliche Gemeinschaftspraxis Quandt und Bracke, Greifswald &
   Tierarztpraxis für Kleintiere Dipl.-Vet.-Med. Andrea Lehmann, Neubrandenburg

Jede Karte verlinkt inzwischen auf die jeweilige Institution/Quelle (Uni Leipzig, Klinik-Website,
Dissertations-Volltext via nbn-resolving.org, Kammerseite zur Zusatzbezeichnung, Praxis-Websites,
DOK, AniCura Potsdam, Quandt und Bracke) – ergänzt nach der ersten Umsetzung.

Jeder Eintrag: `{ date: string, title: string, text: string (markdown) }`.

## Komponenten

- **`layouts/partials/components/timeline.html`** (neu) – generischer, wiederverwendbarer
  Renderer. Nimmt `(dict "Items" $items)`, iteriert und rendert `.timeline` /
  `.timeline-item` / `.timeline-marker` / `.timeline-date` / `.timeline-card` Markup. `text`
  läuft durch `partials/utils/enrich-text.html` (bestehende Konvention für Rich-Text aus
  YAML-Daten).
- **`layouts/shortcodes/timeline.html`** (neu) – dünner Wrapper, den `content/ueber-mich.md`
  aufruft (`{{< timeline data="lebenslauf" >}}`), liest `hugo.Data` (flach, da einsprachig,
  gleiche Fallback-Logik wie `hero.html`) und ruft die Partial auf.
- **`content/ueber-mich.md`** – "## Qualifikation" und "## Berufliche Stationen" werden entfernt
  und durch den einen Shortcode-Aufruf ersetzt. Der einleitende Fließtext (erster Absatz) bleibt
  unverändert vor der Timeline stehen.

## Visuelles Design

- **Farben:** Mittellinie und Punkt-Marker in `var(--color-highlight)` (Meerestürkis, der
  Akzentfarbe der Seite) statt Oliv-Grün aus der Referenz. Datum-Pill im bestehenden
  `.keyword-badge`-Stil (`--color-highlight-soft` Hintergrund, `--color-highlight` Text) statt
  grauer Box.
- **Marker:** Kreisring auf der Linie (weißer/`--color-surface` Kern, `--color-highlight`
  Rand), analog zum Referenzdesign, aber in Türkis statt Oliv.
- **Karte pro Eintrag:** Datum-Pill über dem Titel, Titel in `--color-primary` (wie
  `.markdown-body h2/h3`), Text in `--color-text`/`--color-muted`, verbunden mit dem Marker
  durch einen kurzen horizontalen Strich.
- **Alternierung:** Ungerade Einträge rechts der Linie, gerade Einträge links (oder umgekehrt),
  Text bleibt jeweils linksbündig lesbar (kein rechtsbündiger Fließtext).
- **Desktop (≥768px):** zentrale Linie, Einträge abwechselnd links/rechts, analog zum bestehenden
  768px-Breakpoint-Muster in [main.css:2397](../../../themes/celadon/assets/css/main.css#L2397)
  (`.steps-list`).
- **Mobile (<768px):** Linie und Marker rutschen an den linken Rand, alle Einträge einspaltig
  rechts daneben (kein Alternieren mehr) – üblich für mobile Timelines, konsistent mit dem
  bestehenden mobilen Feinschliff dieser Seite.
- **Kein Bild-Platzhalter** (anders als die schraffierte Box im Referenzdesign) – aktuell keine
  Fotos pro Station vorhanden.

## Betroffene Dateien

- `data/lebenslauf.yaml` (neu)
- `themes/celadon/layouts/partials/components/timeline.html` (neu)
- `themes/celadon/layouts/shortcodes/timeline.html` (neu)
- `themes/celadon/assets/css/main.css` (neue Timeline-Regeln, angelehnt an bestehende
  `.steps-*`-Konventionen)
- `content/ueber-mich.md` (Abschnitte "Qualifikation" + "Berufliche Stationen" durch
  Shortcode-Aufruf ersetzen)

## Verifikation

Kein Test-Setup in diesem Repo (reines Hugo). Verifikation über:

```bash
hugo server
hugo --minify --destination /tmp/out
```

Build muss ohne Warnungen durchlaufen; `/ueber-mich/` manuell im Browser prüfen (Desktop
abwechselnde Timeline, Mobile linksbündige Timeline, Light/Dark-Mode, Linkfarben in den
Textblöcken).
