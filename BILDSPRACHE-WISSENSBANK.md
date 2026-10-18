# Bildsprache der Wissensbank

**Version:** 1.0  
**Geltungsbereich:** Kartenbilder der Übersicht „Wissen“  
**Leitidee:** Fachlich präzise, ruhig und nahbar – im klaren Küstenlicht der Marke

## 1. Ziel

Die Bilder sollen auf den ersten Blick wie eine zusammengehörige Serie wirken. Sie
vermitteln tiermedizinische Kompetenz, ohne klinisch kalt oder werblich künstlich
zu erscheinen.

Die Bildsprache folgt dem Verhältnis aus dem allgemeinen Gestaltungskonzept:

> 80 % hochwertige medizinische Fachpraxis, 20 % maritime Atmosphäre.

Der maritime Bezug entsteht ausschließlich über Licht, Farbe, Ruhe und
Komposition – nicht über dekorative Küstensymbole.

## 2. Visueller Grundstil

### Charakter

- authentisch und fachlich glaubwürdig
- ruhig, klar und hochwertig
- persönlich, aber nicht verniedlichend
- modern, aber nicht modisch oder effektgeladen
- medizinische Details deutlich, jedoch nicht unnötig dramatisch

### Bildaufbau

- ein klar erkennbares Hauptmotiv
- Auge, Tier oder Untersuchungssituation steht im Fokus
- wenig unruhiger Hintergrund
- großzügiger, kontrollierter Bildausschnitt
- bevorzugt Blickrichtung oder Motivschwerpunkt leicht außerhalb der Bildmitte
- wichtige Details nicht direkt an den Kartenrändern platzieren

### Licht

- weiches, natürlich wirkendes Licht
- neutrale bis leicht warme Haut-, Fell- und Gewebetöne
- klare Glanzlichter im Auge dürfen als verbindendes Motiv sichtbar bleiben
- keine harten HDR-Kontraste, ausgefressenen Lichter oder tiefschwarzen Schatten

## 3. Gemeinsamer Farblook

Alle Bilder erhalten eine zurückhaltende, natürliche Farbkorrektur:

- leicht reduzierte Gesamtsättigung
- ausgewogener Weißabgleich
- sanft angehobene Schatten
- moderate Kontraste
- Petrol und Meerestürkis nur als subtile Akzente
- Sandgold sparsam in Licht oder warmen Fellfarben
- Weiß und helles Meeresgrau für ruhige Hintergründe

Markenfarben:

| Rolle | Farbe |
|---|---:|
| Tiefes Petrol | `#06475F` |
| Meerestürkis | `#03AAB0` |
| Sandgold | `#E8BA7B` |
| Warmes Elfenbein | `#FAF8F3` |
| Helles Meeresgrau | `#EEF4F3` |
| Dunkles Petrolgrau | `#12303A` |

Ein Farbüberzug ist nur sehr dezent zulässig. Medizinisch relevante Farben
dürfen durch die Bearbeitung nicht verändert oder verschleiert werden.

## 4. Stil nach Inhaltskategorie

### Wissensbank

**Motiv:** medizinische Nahaufnahme, Tierporträt mit erkennbarem Augenbezug oder
authentische Untersuchungssituation.

- sachlich und präzise
- Erkrankung oder anatomisches Merkmal klar erkennbar
- keine dramatisierende Inszenierung
- keine dekorative Beschriftung im Bild

### Patientengeschichten

**Motiv:** individuelles Tierporträt oder ruhige Behandlungssituation.

- etwas wärmer und persönlicher als die Wissensbank
- das Tier bleibt als Patient und Persönlichkeit erkennbar
- natürlicher Blick und glaubwürdige Umgebung
- keine Kostüme, Vermenschlichung oder übertriebene Niedlichkeit

### Vorträge, Poster und Publikationen

**Motiv:** ein gestaltetes Editorial-Cover statt eines verkleinerten
Folienscreenshotss.

- ruhige Fläche in Elfenbein, Meeresgrau oder Petrol
- ein aussagekräftiges medizinisches Foto oder reduziertes Fachmotiv
- kurze Kennzeichnung wie „Vortrag“, „Publikation“ oder „Poster“
- höchstens ein kurzer Titel; vollständige Veranstaltungstitel bleiben im
  Kartentext
- wiederkehrendes Layout für die gesamte Kategorie

Logos und Originalposter dürfen im Artikel selbst erscheinen, sind aber in der
kleinen Kartenansicht in der Regel kein geeignetes Hauptmotiv.

## 5. Technischer Bildstandard

- **Seitenverhältnis:** `16:9`
- **Arbeitsgröße:** mindestens `1600 × 900 px`
- **Ausgabeformat:** bevorzugt WebP, JPEG bei fotografischen Ausnahmen
- **Farbraum:** sRGB
- **Qualität:** WebP etwa 80–85, JPEG etwa 82–88
- **Zielgröße:** möglichst unter 250 KB pro Kartenbild
- **Schärfung:** nur leicht nach der finalen Skalierung
- **Dateiname:** klein, beschreibend, ohne Umlaute und Leerzeichen

Beispiele:

```text
glaukom-hund-wissensbank.webp
abby-patientengeschichte.webp
fvo-2024-hornhautchirurgie.webp
```

## 6. Zuschnitt und Fokus

Der Master wird bereits als 16:9-Bild angelegt. Automatischer Beschnitt ist nur
die letzte Absicherung.

- Augen und medizinisch wichtige Details müssen vollständig sichtbar bleiben.
- Bei Tierporträts nicht durch Augen, Ohren oder Schnauze schneiden.
- Bei extremer Nahaufnahme einen kleinen visuellen Sicherheitsrand lassen.
- Text und Logos mindestens 8 % vom Rand entfernt halten.
- Für abweichende Motive wird später ein individueller Fokuspunkt hinterlegt.

Empfohlene Inhaltsangabe:

```yaml
image: "/images/wissen/glaukom-hund-wissensbank.webp"
image_position: "50% 45%"
```

## 7. Umgang mit medizinischen Bildern

- Diagnosebilder inhaltlich nicht manipulieren.
- Keine Symptome hinzufügen, entfernen oder verstärken.
- Keine generative Retusche am erkrankten Auge.
- Zulässig sind Zuschnitt, Belichtung, Weißabgleich, moderate Farbkorrektur,
  Rauschminderung und behutsame Hintergrundberuhigung.
- Bei Blut, Wunden oder Operationen den fachlich notwendigen Ausschnitt zeigen,
  aber unnötig drastische Darstellungen in der Übersicht vermeiden.
- KI-generierte Bilder dürfen keine konkrete Erkrankung oder Behandlung als
  scheinbar echte Dokumentation darstellen.

## 8. Einsatz generierter Illustrationen

Generierte Bilder werden nur eingesetzt, wenn kein geeignetes authentisches
Foto vorhanden ist oder ein abstraktes Titelmotiv benötigt wird.

Der zulässige Illustrationsstil ist:

- editorial und halb-realistisch
- ruhige, reduzierte Flächen
- natürliche Anatomie und Proportionen
- weiches Licht
- begrenzte Markenpalette
- keine Cartoon-, 3D-Render-, Hochglanz-Werbe- oder Fantasy-Ästhetik

Generierte Motive dürfen nicht enthalten:

- übergroße oder leuchtende Augen
- menschliche Mimik bei Tieren
- medizinisch unplausible Instrumente oder Anatomie
- Text, Wasserzeichen oder erfundene Logos
- überzeichnete Schmerzen oder Angst

## 9. Wiederkehrendes Gestaltungselement

Um die Serie subtil zu verbinden, kann jedes nicht-dokumentarische Titelbild
eines der folgenden Elemente verwenden:

- eine weiche horizontale Lichtfläche
- eine sehr dezente geschwungene Augen-/Wellenlinie
- einen kleinen sandgoldenen Lichtakzent

Das Element bleibt im Hintergrund und darf das Hauptmotiv nicht überlagern.
Direkte maritime Symbole wie Möwen, Anker, Muscheln oder Segelboote werden nicht
verwendet.

## 10. Nicht verwenden

- uneinheitliche Stockfoto- und KI-Stile
- stark übersättigte Farben
- dramatische Vignetten, Lens Flares oder HDR-Look
- Collagen mit vielen kleinen Einzelbildern
- unlesbare Screenshots von Folien oder Postern
- sichtbare Wasserzeichen oder Stockfoto-Markierungen
- mehrfach verwendete Kartenbilder für unterschiedliche Beiträge
- dekorativer Text auf medizinischen Fotos
- Motive, deren entscheidender Inhalt durch den Kartenzuschnitt verloren geht

## 11. Auswahl- und Abnahmecheck

Ein Kartenbild wird nur übernommen, wenn alle Fragen mit „Ja“ beantwortet werden:

1. Ist das Motiv dem Beitrag eindeutig zuzuordnen?
2. Wirkt es fachlich glaubwürdig und anatomisch korrekt?
3. Passt es zum ruhigen, natürlichen Gesamtstil?
4. Funktioniert der Ausschnitt auch als kleine 16:9-Vorschau?
5. Bleiben medizinisch relevante Farben und Details unverfälscht?
6. Unterscheidet es sich klar von den Bildern anderer Beiträge?
7. Enthält es keine unlesbaren Texte, Wasserzeichen oder störenden Artefakte?
8. Ist die Nutzung beziehungsweise Bildquelle dokumentiert?

## 12. Vorgehen bei der Aktualisierung

Für jeden Beitrag wird in dieser Reihenfolge entschieden:

1. vorhandenes authentisches Foto passend zuschneiden und farblich angleichen,
2. ein besseres vorhandenes Foto aus dem Artikelbestand auswählen,
3. ein neues authentisches Foto vorsehen,
4. nur bei Bedarf ein redaktionelles Titelmotiv gestalten oder generieren.

Die Umstellung erfolgt zunächst an drei Referenzkarten – je eine pro Kategorie.
Nach deren visueller Abnahme dienen sie als Vorlage für alle weiteren Bilder.
