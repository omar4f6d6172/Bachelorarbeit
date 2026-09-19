# Bachelorarbeit

Untersuchung von Watchdog- und Recovery-Strategien für ein robustes eingebettetes System.

- [Typst-Hauptdatei](typst/bachelorarbeit.typ)
- [Kompilierte PDF](output/pdf/bachelorarbeit-typst.pdf)
- [Projektaufbau und Anleitung](typst/README.md)
- [Hinweise zu Textlücken und fehlenden Anhängen der Vorlage](typst/HINWEISE_ZUR_VORLAGE.md)
- [Original-PDF](Bachelorarbeit_nach_Professor_Kerdels_Korrekturen_v1-1.pdf)

## Kompilieren

Mit Typst 0.14.2 oder einer kompatiblen Version aus dem Repository-Verzeichnis:

```sh
make
```

`make` oder `make watch` kompiliert sofort und aktualisiert die PDF bei Änderungen an den Typst-Dateien und eingebundenen Dateien automatisch. Mit `Strg+C` beenden. Die Ausgabe liegt unter `output/pdf/bachelorarbeit-typst.pdf`.

Für eine einmalige Kompilierung: `make build`. Voraussetzung sind `make` und `typst` im Suchpfad.

Das Projekt benötigt keine externen Typst-Pakete. Text, Tabellen, Formeln und Quelltextblöcke sind bearbeitbar; die Abbildungen wurden aus der Vorlage übernommen.
