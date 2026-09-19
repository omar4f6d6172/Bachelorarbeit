# Bachelorarbeit in Typst

Einstieg: `bachelorarbeit.typ`. Klassisches Layout für die digitale PDF-Abgabe, ohne externe Typst-Pakete und ohne Netzwerkzugriff beim Kompilieren.

## Erstellen

Im Projektordner:

```sh
make build
```

Ausgabe: `output/pdf/bachelorarbeit-typst.pdf`. `make` oder `make watch` startet die automatische Neukompilierung; mit `Strg+C` beenden. Geprüft mit Typst 0.14.2. Benötigte Schriften: **Libertinus Serif**, **New Computer Modern Math** (Formeln) und **DejaVu Sans Mono** (Code).

## Gestaltung

- A4, Hochformat, 25 mm Seiten- und oberer Rand, 24 mm unterer Rand.
- Libertinus Serif, Fließtext 11,5 pt, deutscher Blocksatz, Zeilenzugabe 0,65 em. Diese Typst-Zeilenzugabe ist kein prozentualer Zeilenabstand.
- Überschriften 19 / 14 / 12 pt; Hauptkapitel beginnen auf neuer Seite.
- Titelblatt ohne Seitenzahl; Vorseiten römisch und Hauptteil arabisch ab 1. Navigation über PDF-Lesezeichen und anklickbare Verzeichnisse und Verweise.
- Tabellen und Bildunterschriften 10 pt, Quelltext 8,5 pt ohne farbige Syntaxhervorhebung. Schlusskapitel mit geringfügig kompakterem Absatzsatz, um eine Restseite zu vermeiden.
- Acht Diagramme als native, farbige Vektorgrafiken mit einer drucktauglichen akademischen Farbpalette. Sämtliche Zahlen, Übergänge und Beschriftungen können im Typst-Quelltext bearbeitet werden.

## Dateien

| Datei / Ordner | Aufgabe |
| --- | --- |
| `bachelorarbeit.typ` | Titelblatt, Satzregeln, Reihenfolge der Teile, Verzeichnisse und Seitenzählung |
| `layout.typ` | Abbildungen, Tabellen, Gleichungen, Quellenverweise und automatische Nummerierung |
| `diagramme.typ` | Acht native Architektur-, Ablauf-, Zustands- und Messdiagramme |
| `kapitel/00.typ` | Deutsche Zusammenfassung |
| `kapitel/01.typ` bis `07.typ` | Sieben Kapitel mit bearbeitbarem Fließtext |
| `abkuerzungen.typ` | Alphabetisches Abkürzungsverzeichnis |
| `tabellen/` | Native Tabellen; Tabelle 5.2 ist ein zusammenhängender Testkatalog |
| `abbildungen/` | Unveränderte Originalgrafiken als Referenz; nur der Terminal-Screenshot wird noch eingebunden |
| `literatur.typ` | 28 Literatureinträge mit stabilen Labels und anklickbaren DOI-/URL-Adressen |
| `OFFENE_ABGABEPUNKTE.md` | Fehlende Inhalte und Aufgaben vor der Abgabe, außerhalb der Arbeit |
| `HINWEISE_ZUR_VORLAGE.md` | Dokumentation der ursprünglichen Textlücken und Übertragungsentscheidungen |

## Nummerierung und Verweise

Abbildungen und Tabellen erhalten über `vorlage` beziehungsweise `echtetabelle` eine automatisch erzeugte Kapitelnummer. Gleichungen werden mit `gleichung` gesetzt. Labels wie `<abb-3-1>`, `<tab-5-3>` oder `<sec-3-8>` sind stabile interne IDs; ihre Ziffern sind keine festgeschriebenen Anzeigezahlen. Bestehende Labels bei Umstellungen beibehalten. Im Text `#ref(<tab-5-3>, supplement: [Tabelle])` verwenden.

Literatureinträge verwenden `#lit(<lit-01>, [Eintrag])`, Zitate beispielsweise `\[#quelle(<lit-01>), S. 13–14\]`. Angezeigt wird die aktuelle Position im Literaturverzeichnis. Die bisherige Reihenfolge und der numerische Zitierstil bleiben erhalten; es gibt keine automatische externe Quellenrecherche oder CSL-Umformatierung.

Die native Tabelle 5.3 fasst Szenario und Messgröße in einer Spalte sowie Minimum und Maximum als Intervall zusammen. Messwerte und Stichprobengrößen bleiben erhalten. Im Messdiagramm zur Unterspannung sind die Zustandsklassen ordinal: Abstände und Verbindungslinien stellen keine metrischen Zustandsabstände oder gemessenen Schwellenspannungen dar.

## Inhaltlicher Stand

Die Gestaltung ergänzt keine fehlenden Fachinhalte. Anhänge A–D und Teile von Sätzen fehlen bereits in der Vorlage. Vor der Abgabe die separate Liste `OFFENE_ABGABEPUNKTE.md` bearbeiten.
