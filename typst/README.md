# Bachelorarbeit in Typst

Einstieg: `bachelorarbeit.typ`. Das Projekt benötigt keine externen Typst-Pakete und keine Verbindung zum Internet beim Kompilieren.

## Kompilieren

Im übergeordneten Projektordner:

```sh
typst compile typst/bachelorarbeit.typ output/pdf/bachelorarbeit-typst.pdf
```

Alternativ im Ordner `typst`:

```sh
typst compile bachelorarbeit.typ bachelorarbeit.pdf
```

Geprüft mit Typst 0.14.2. Verwendete Schriften: New Computer Modern, Noto Sans und DejaVu Sans Mono.

## Dateien

- `bachelorarbeit.typ`: Titelblatt, Satzspiegel, Überschriften, Seitenzählung und automatisch erzeugte Verzeichnisse.
- `layout.typ`: wiederverwendbare Bausteine für Tabellen, Abbildungen und Literatur.
- `kapitel/00.typ`: Zusammenfassung.
- `kapitel/01.typ` bis `07.typ`: die sieben Kapitel mit bearbeitbarem Fließtext. Kommentare verweisen auf die Seiten der Vorlage.
- `abkuerzungen.typ`: bearbeitbares Abkürzungsverzeichnis.
- `tabellen/`: aus Bildtabellen rekonstruierte, native Typst-Tabellen. Die Tabellen 3.5, 4.1 und 5.5 stehen unmittelbar in den jeweiligen Kapiteln.
- `abbildungen/`: neun aus der Vorlage übernommene Abbildungen. Diagramme und Screenshot bleiben Grafiken, deren Beschriftung in der jeweiligen Bilddatei enthalten ist.
- `literatur.typ`: alle 28 nummerierten Literatureinträge; die angegebenen URLs sind anklickbar.
- `HINWEISE_ZUR_VORLAGE.md`: Textlücken und technische Besonderheiten der PDF-Vorlage.

## Umfang der Übertragung

Übertragen wurden Titelblatt, Zusammenfassung, Abkürzungen, sieben Kapitel, zwölf Tabellen (Tabelle 5.2 in zwei Teilen), neun Abbildungen, fünf Formeln, die vorhandenen Quelltextblöcke und alle 28 Literaturangaben. Fließtext, Tabellen, Formeln und Code sind bearbeitbarer Typst-Inhalt. Die PDF-Seiten wurden nicht als Ganzseitenbilder eingebunden.

Überschriftennummerierung, Inhalts-, Abbildungs- und Tabellenverzeichnis sowie Seitenzahlen werden neu erzeugt. Deshalb ändern sich Umbrüche und Seitenzahlen gegenüber der 66-seitigen Vorlage. Die breite Ergebnistabelle 5.3 steht im Querformat. Die fachlichen Zahlenwerte wurden übernommen und nicht neu berechnet.

Die Abschnittsnummern werden automatisch erzeugt. Tabellen-, Abbildungs- und Gleichungsnummern sowie Literaturverweise behalten die Originalbezeichnungen; bei strukturellen Erweiterungen sind diese Bezeichnungen entsprechend anzupassen. Eine fachliche Prüfung oder Quellenrecherche ist nicht Bestandteil dieser Formatübertragung.
