# Hinweise zur PDF-Vorlage

Quelle: `Bachelorarbeit_nach_Professor_Kerdels_Korrekturen_v1-1.pdf`, 66 PDF-Seiten.

Die PDF enthält nachträglich aufgebrachte Textkorrekturen und weiße Überdeckungen. Eine einfache Textextraktion liefert deshalb alte und neue Texte doppelt. Für die Übertragung wurden die sichtbaren Korrekturen berücksichtigt und verdeckte alte Textstände ausgeschlossen. Nicht eindeutig rekonstruierbare Aussagen wurden nicht fachlich ergänzt. Die folgenden Seitenangaben beziehen sich auf die Position der Seite in der ursprünglichen PDF, nicht auf ihre gedruckte Seitenzahl.

## Offene Stellen in der Vorlage

| PDF-Seite | Stelle | Befund |
| --- | --- | --- |
| 16 | 2.8 Timeout-Dimensionierung | Korrekturtext reicht über den rechten Seitenrand; im Satz steht „zwischen zwei gültige Fortschrittsmeldungen“. |
| 29 | 4.1 Hardwareaufbau | Der rechte Seitenrand schneidet den Text nach „… und der ST“ ab. Die Fortsetzung beginnt mit „steuert das LCD …“. |
| 31 | 4.2.4 Netzwerkdienst | Ein isoliertes „u“ am äußersten rechten Rand ist als Restzeichen vorhanden. Es ist im übertragenen Text weiterhin erkennbar. |
| 31 | 4.2.5 UART-Dienst | Der Text endet mit „Bei“ und setzt mit „Position verfügbar, lautet der Zustand …“ fort; dazwischen fehlt ein Satzteil. |
| 32 | UART-Listing | Die Vorlage zeigt zwei Backslashes vor `n` in der f-Zeichenkette. Dies wurde wörtlich beibehalten, nicht als Programmkorrektur geändert. Die Einrückung des Python-Beispiels wurde wiederhergestellt. |
| 56 | 6.1.4 | Der letzte Absatz endet mit einem Semikolon nach „… innerhalb des untersuchten Aufbaus;“. |
| 58 | 6.7 Unterspannungsverhalten | Ein Absatz endet unvollständig mit „… einem degradierten Systemzustand,“; danach beginnt ein anderer Absatz. |
| 59 | 6.8.3 Externe Validität | Ein Satz endet nach „… dem in dieser Arbeit“; danach beginnt „Andere SD-Karten …“. |
| 61 | 7.1 Fazit | Im Satz „… auf dem Raspberry Pi belegte … eine aktive Unterspannung …“ fehlt das Subjekt bzw. der Statuswert. |
| 61 | 7.1 Fazit | Im Satz „Für den in dieser Arbeit untersuchten … und die durchgeführten Versuche …“ fehlt ein Satzteil. |

Mehrere weitere auffällige Leerstellen der Vorlage sind durch weiße Überdeckungen entstanden. Sie wurden nicht durch mutmaßlich ältere, verdeckte Aussagen ersetzt.

## Fehlende Anhänge

Die gelieferte PDF endet nach dem Literaturverzeichnis. Im ursprünglichen Inhaltsverzeichnis und im Text stehen Verweise auf Anhänge A–D, beispielsweise auf Anhang A und Quelltext C.6. Die entsprechenden Seiten sind nicht in der gelieferten Datei enthalten und wurden nicht erfunden. Das neu erzeugte Inhaltsverzeichnis enthält nur tatsächlich vorhandene Abschnitte; die Verweise im Fließtext bleiben erhalten.

## Bereinigung von Konvertierungsartefakten

- Verdeckte alte Einträge im Inhaltsverzeichnis wurden durch ein neu erzeugtes Verzeichnis ersetzt.
- Die sichtbare korrigierte Gliederung mit Abschnitt 1.5 „Aufbau der Arbeit“ und 6.9 „Gesamtbewertung“ wurde übernommen.
- Auf PDF-Seite 60 wurde der doppelte, isolierte erste Satz der Gesamtbewertung nicht ein zweites Mal eingefügt.
- Technische Leerzeichenzeichen (`␣`) wurden in normale Leerzeichen umgewandelt; offensichtliche Zeichencodierungsfehler wie `gröSS` und `anschlieSSend` wurden normalisiert.
- Zeilenbedingte Worttrennungen, mehrfach auftauchende Code-Zeilennummern sowie laufende Kopf- und Fußzeilen wurden bereinigt. Kopfzeilen und Seitenzahlen erzeugt Typst neu.
- Bei den Bildtabellen wurden technische Escape-Artefakte vor Unterstrichen in Bezeichnern wie `APP_RUNTIME` entfernt.
- Abbildungen wurden unverändert inhaltlich übernommen und bei Bedarf von fremden Kopfzeilen befreit. Die ursprünglich im Fließtext platzierten Abbildungen wurden teils an die zugehörigen vollständigen Absätze verschoben.

## Prüfung der ursprünglichen Übertragung

Die Typst-Datei wurde erfolgreich kompiliert. Geprüft wurden die vollständige Seitenübersicht, ausgewählte Seiten in Originalgröße, Verzeichnisse, Tabellen, Formeln, Codeblöcke und das Literaturverzeichnis. Alle 28 Literatureinträge und neun Abbildungen sind enthalten. Es wurden keine über den Seitenrand reichenden Textblöcke festgestellt. Die hier beschriebenen Textlücken sind bereits in der Vorlage vorhanden.


## Anschließende Gestaltungsüberarbeitung

Das klassische digitale Layout, automatische Verweise und die acht nativen Diagramme
sind in `README.md` beschrieben. Die PNG-Originale bleiben als Referenz erhalten;
der Terminal-Screenshot wird mit einem Sichtfenster ohne eingebrannte Bildunterschrift
angezeigt. Diese Layoutänderungen beseitigen keine der oben dokumentierten Textlücken.
Die noch zu bearbeitenden Abgabepunkte stehen separat in `OFFENE_ABGABEPUNKTE.md`.


## Stand nach der formalen Review-Korrektur

Die obige Tabelle dokumentiert den Zustand der Originalvorlage. Die eindeutigen
Sprach- und Satzzeichenfehler in 2.8, 4.2.4, 6.1.4 und 6.7 wurden inzwischen
korrigiert. Inhaltlich unvollständige Stellen, insbesondere in 4.1, 4.2.5, 6.8.3
und 7.1, sowie das UART-Listing bleiben zur fachlichen Klärung offen.
Die konkret vorgenommenen Korrekturen stehen in `OFFENE_ABGABEPUNKTE.md`.
