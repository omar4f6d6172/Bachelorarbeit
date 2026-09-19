# Inhaltliche Revision – Red Flags und minimale Korrekturen

**Ziel:** Die erkennbaren Abgaberisiken beseitigen. Was fachlich vertretbar ist, bleibt. Keine Optimierung auf eine besonders gute Note und keine grundlegende Neuausrichtung.

**Unverändert bleiben:** Thema, Zielsetzung, Forschungsfragen, Aufbau aus Raspberry Pi und STM32 sowie die Untersuchung abgestufter Watchdog- und Recovery-Strategien. Die Arbeit wird weder zu einem anderen Projekt umgeschrieben noch um zusätzliche Funktionen erweitert.

**Status:** Bearbeitbarer Plan. Die hier vorgeschlagenen fachlichen Änderungen sind noch nicht umgesetzt. Die Rangfolge ist meine Einschätzung anhand des Reviews und des Manuskripts, keine verbindliche Aussage über die Bewertung durch die Prüfer oder eine Bestehensgarantie.

**Grundlage:** Review vom 19. September 2026 zur älteren 47-Seiten-Fassung. Die aktuelle PDF hat 44 Seiten. Die genannten Exportfehler und eindeutigen formalen Fehler sind bereits separat korrigiert.

## Die Red Flags, nach Risiko geordnet

| Rang | Thema | Warum kritisch? | Kleinste vertretbare Korrektur | Bleibt erhalten |
| --- | --- | --- | --- | --- |
| **1** | Fehlende zentrale Nachweise und leere Anhangverweise | Zentrale Aussagen berufen sich auf nicht zugängliche Belege. Besonders problematisch, wenn die Belege tatsächlich nicht mehr existieren. | Vorhandene Kernbelege zugänglich machen; endgültig leere Verweise auflösen und davon abhängige Aussagen begrenzen. | Arbeit, Architektur und tatsächlich nachvollziehbare Ergebnisse |
| **2** | P2: 60 s als Hardware-Timeout und spekulative Erklärung der 35 s | Technisch angreifbare Erklärung eines zentralen Versuchs. | Unbelegte Hardware-Deutung und Restintervall-Erklärung streichen; 35 s als externes Netzwerkintervall ausweisen. | P2 als konkreter Kernel-Panic-Test und belegte Beobachtungen |
| **3** | L1: 44/46 ms als vollständige Recovery-Zeit | Start der Messung ist Bedienerbestätigung, nicht elektrische Leitungsänderung. | Werte als Bestätigung-bis-Status-Intervalle benennen; daraus keinen elektrischen Geschwindigkeitsvorteil ableiten. | L1, seine Zahlen mit korrekter Bedeutung und der belegte lokale Funktionsnachweis |
| **4** | Falscher Python-Zeilenabschluss und widersprüchliche/unvollständige Sätze | Direkt erkennbare Fehler schwächen die Glaubwürdigkeit der Implementierungsbeschreibung. | Listing mit Originalcode abgleichen; GPS-Satz und bedeutungsrelevante Satzabbrüche korrekt vervollständigen. | Implementierung und Beschreibung, soweit belegt |
| **5** | H1: 5,70 s ohne Hinweis auf verkürzten IWDG | Testkonfiguration wird zur allgemeinen Laufzeitaussage verallgemeinert. | Den verkürzten Diagnose-Timeout überall mitnennen. | H1 einschließlich Messwert, Tabelle und Diagramm |
| **6** | Unterschiedliche Messgrößen und zu starke F2-Antwort | Verschiedene Fehler, Endpunkte und Timeouts belegen keinen isolierten Einfluss der Eingriffstiefe. | Messgrößen kurz unterscheiden; wenige zu starke Schlussfolgerungen zurücknehmen. | Forschungsfrage F2, die Vergleiche und die Richtung der Arbeit |

**Arbeitsregel:** Bei diesen sechs Punkten gezielt korrigieren. Bei den übrigen Punkten reicht überwiegend eine klare Grenze oder eine kurze Erläuterung. Nicht jede Schwäche rechtfertigt einen Umbau.

## Rang 1: Nachweise – zuerst klären, was tatsächlich fehlt

**Review:** T07; betroffen sind insbesondere Anhänge A–D, Quelltext C.6 und das Evaluationsarchiv.

Der Review hatte keinen Originalcode und keine Rohdaten. Das bedeutet zunächst nur: Sie lagen dieser Prüfung nicht vor. Es beweist nicht, dass die Versuche unbelegt oder nicht durchgeführt sind.

**Minimalplan:**

1. Feststellen, welche Originaldateien noch vorhanden sind und welche zum Versuch gehören.
2. Die für zentrale Aussagen benötigten Belege in einen kleinen Anhang oder eindeutig benannte Begleitdateien aufnehmen.
3. Verweise auf endgültig fehlende Dateien entfernen oder deren fehlende Verfügbarkeit ausdrücklich erklären.
4. Prüfen, ob durch einen fehlenden Beleg auch die damit begründete Aussage zu stark wird.

**Nicht erforderlich als pauschales Ausbauziel:** Ein perfektes Reproduktionspaket mit jeder Bibliotheksversion und umfangreicher neuer Infrastruktur. Vorrang haben die Nachweise, auf die sich die zentralen Ergebnisse tatsächlich stützen. Konkrete Abgabeanforderungen bleiben einzuhalten.

**Nicht ausreichend:** Nur die leeren Verweise löschen, während die unbelegte Schlussfolgerung unverändert stehen bleibt. Ein Hash ersetzt kein zugängliches Archiv. Fehlende Genauigkeitsangaben können offen bleiben; ein nicht nachvollziehbarer zentraler Ergebniswert braucht eine eigene Entscheidung.

**Deine Bestandsaufnahme:**

| Material | Vorhanden / Fundort | Zum damaligen Versuch gehörig? |
| --- | --- | --- |
| Raspberry-Pi-Code und STM32-Firmware | | |
| Testskripte und Rohlogs/CSV | | |
| Watchdog-Konfiguration und `wdctl`-Auszug | | |
| Evaluationsarchiv / Anhänge | | |

- [ ] Kernbelege gefunden oder verbleibende Lücken konkret benannt

## Rang 2: P2 – die Erklärung kürzen, den Versuch behalten

**Review:** T01. **Stellen:** 4.4, 5.5.11, 6.6.

**Streichen:**

- „wirksamer Hardware-Timeout von 60 s“, solange nicht belastbar nachgewiesen;
- die Vermutung, ein Teil eines physischen 60-s-Intervalls sei bereits vergangen;
- jede nicht gemessene Zerlegung der 35 s in Hardware-Auslösezeit, Bootzeit usw.

**Behalten:** Den konkreten Kernel-Panic-Test, die berichteten zwei Funktionsnachweise und die eine gültige externe Zeitmessung, soweit die Versuchsunterlagen diese tragen. Die genaue Timeout-Abweichung darf als ungeklärt stehen bleiben. Wenn bereits die Ursache des Neustarts nicht nachweisbar ist, diese nicht als abschließend bewiesen ausgeben.

**Knapper Ersatztext, nach Abgleich der Versuchsereignisse:**

> Nach der injizierten Kernel-Panic wurde in zwei Durchläufen eine automatische Wiederherstellung beobachtet. Für einen Durchlauf liegt eine externe Netzwerknichtverfügbarkeit von 35 s vor. Daraus lässt sich die reine Hardware-Auslösezeit nicht bestimmen. Die Abweichung zwischen angeforderter Konfiguration und gemeldetem Timeout wurde nicht abschließend geklärt.

**Kein neuer Versuch nötig, nur um die spekulative Erklärung zu retten.** Die 60 s auch nicht einfach durch einen aus anderer Dokumentation abgeleiteten Wert ersetzen.

Hintergrund: Die [Linux-Watchdog-Dokumentation](https://docs.kernel.org/watchdog/watchdog-kernel-api.html) unterscheidet logischen Timeout und maximale Hardware-Heartbeat-Frist. Sie identifiziert nicht die damalige Versuchskonfiguration.

- [ ] Entscheidung: Korrektur wie vorgeschlagen

**Notizen:**

> 

## Rang 3: L1 – Messwert behalten, falsche Bedeutung entfernen

**Review:** T02. **Stellen:** 5.3.4, 5.5.1, 5.5.9, Tabelle 5.3 und Diskussion.

**Minimaländerung:** Die 0,046 s und 0,044 s ausdrücklich als Intervalle von der Bedienerbestätigung bis zum protokollierten FAIL-/OK-Status ausweisen. Das steht teilweise bereits in der Tabelle; die Interpretation muss dazu passen.

**Ergänzung:**

> Diese Werte erfassen nicht die vollständige Zeit ab elektrischer Leitungsänderung. L1 zeigt die beobachtete lokale Zustandswiederherstellung ohne Mikrocontroller-Reset; eine elektrische Recovery-Latenz wurde damit nicht bestimmt.

**Streichen:** L1 als Beleg dafür, dass vollständige lokale Hardware-Recovery nur wenige Millisekunden dauert. U1/U2 messen wiederum andere Vorgänge und dürfen diese Aussage nicht stellvertretend tragen.

**Bleibt:** Versuch, Werte, lokale Recovery und ihre Einordnung in die Architektur. Eine Umbenennung und ein klarer Einschränkungssatz reichen, sofern die protokollierten Start-/Endereignisse stimmen. Keine nachträglich geschätzten Ersatzzeiten einsetzen.

- [ ] Entscheidung: Werte mit dieser Einschränkung behalten

**Notizen:**

> 

## Rang 4: Offensichtlich falsche Darstellungen korrigieren

**Review:** T04, T10 und verbleibender inhaltlicher Teil von F04.

| Stelle | Minimale Korrektur |
| --- | --- |
| Python-Listing 4.2.5 | Mit Originalcode abgleichen. Für den beschriebenen LF-Abschluss ein einzelnes `\n` im Python-Stringliteral zeigen. Nicht ungeprüft behaupten, auch die laufende Anwendung sei fehlerhaft gewesen. |
| GPS-Satz 4.2.5 | Aktuellen gültigen Fix und zulässige letzte Position korrekt unterscheiden. Den widersprüchlichen Satz nicht stehen lassen. |
| „der ST“ in 4.1 | Nach Abgleich mit der beschriebenen Hardware eindeutig STM32 benennen. |
| Satzabbruch 6.8.3 | Vorhandene Aussage zur begrenzten Übertragbarkeit vollständig formulieren. |
| Fehlendes Subjekt in 7.1 | Den tatsächlich verwendeten Unterspannungsbeleg benennen, etwa `0x50005`, sofern der Screenshot gemeint ist. |
| „Für den … untersuchten und die … Versuche“ | „Für den untersuchten Aufbau und die durchgeführten Versuche …“ |

**GPS-Entwurf, sofern die Implementierung das bestätigt:**

> Bei fehlendem aktuellem GPS-Fix und einer noch zulässigen zuletzt gültigen Position wird `GPS=ERR;MODE=LAST` übertragen. Bei gültigem aktuellem Fix wird `MODE=LIVE` verwendet.

**Was bleibt offen?** Verhalten ohne gültige Fallback-Position nur entsprechend dem tatsächlichen Code beschreiben. Falls kein Originalcode verfügbar ist, ein korrigiertes Listing als erläuterndes Beispiel kennzeichnen, nicht als verifizierten Originalauszug.

**Hier würde ich nicht sparen:** Klare Widersprüche und Satzabbrüche lassen sich nicht sinnvoll als bloße Einschränkung rechtfertigen.

- [ ] Entscheidung: Diese Stellen gezielt korrigieren

**Notizen / Codefundort:**

> 

## Rang 5: H1 – ein Zusatz statt eines neuen Experiments

**Review:** T03. **Stellen:** Zusammenfassung, 5.5.5, Tabelle 5.3, Abbildung 5.1, Diskussion und Fazit.

**Durchgehend ergänzen:** „H1 mit verkürzter IWDG-Periode“ beziehungsweise „H1-Diagnosepfad“.

> Im H1-Diagnosepfad mit verkürzter IWDG-Periode wurde der Applikationsmodus nach 5,70 s wieder erreicht. Der Wert gilt für diese Testkonfiguration.

**Behalten:** Test, Zahl, Balken und Ergebnisbeschreibung. Ein Diagrammumbau ist nicht nötig; eine eindeutige Kennzeichnung und der Hinweis auf unterschiedliche Testbedingungen genügen für diese begrenzte Darstellung.

**Nicht behaupten:** 5,70 s als allgemeine normale Watchdog-Recovery-Zeit oder 10-ms-Messgenauigkeit allein aufgrund gleicher gerundeter Werte.

**Kein Normalbetrieb-Vergleich als Pflichtprojekt:** Falls die normalen Parameter im Code leicht auffindbar sind, ergänzen. Sonst keine zusätzlichen Versuche nur zur Aufwertung der Arbeit einplanen.

- [ ] Entscheidung: H1 mit Einschränkung behalten

**Notizen:**

> 

## Rang 6: Vergleich und F2 – Richtung und Forschungsfrage bleiben

**Review:** T05/T06. **Stellen:** Messmethodik, Ergebnisübersicht, 6.1.2, Zusammenfassung und Fazit.

**F2 bleibt unverändert:**

> Wie unterscheiden sich lokale Recovery, Dienstneustart, Mikrocontroller-Reset und vollständiger Systemneustart hinsichtlich Eingriffstiefe und funktionaler Wiederherstellungszeit?

Die Antwort darf ergeben, dass die Daten keinen isolierten Einfluss der Eingriffstiefe bestimmen. Dafür muss die Forschungsfrage nicht ersetzt werden.

**Minimaländerungen:**

- Die tatsächlich verwendeten Start- und Endereignisse pro Messkategorie knapp nennen; bei Bedarf als Zusatzspalte oder kurze Legende.
- P1/P2 als externe Netzwerknichtverfügbarkeit bezeichnen, nicht als vollständige Anwendungsbereitschaft. Bei P1 kann eine stromlose Phase enthalten sein.
- L1 gesondert kennzeichnen; U1/U2 als Zeit bis Fehlerantwort beschreiben, soweit dies der Messung entspricht.
- Den Satz zurücknehmen, die gemessene Abstufung beweise den Einfluss der Eingriffstiefe auf die Zeit.

**Ersatz für die zu starke Schlussfolgerung:**

> Die untersuchten Fehlerfälle zeigen unterschiedliche Wiederherstellungszeiten. Wegen unterschiedlicher Fehlerarten, Timeout-Einstellungen und Messendpunkte lässt sich daraus kein isolierter zeitlicher Einfluss der Eingriffstiefe ableiten. Die Versuche zeigen jedoch für die dokumentierten Fälle, dass lokale Maßnahmen eine Wiederherstellung ohne vollständigen Neustart ermöglichten.

**Bleibt:** Die Argumentation für abgestufte Recovery, die Architektur und der Vergleich der konkreten Fälle. Die Behauptung einer allgemeinen zeitlichen Überlegenheit entfällt. Literatur kann das Entwurfsprinzip weiterhin begründen.

- [ ] Entscheidung: Forschungsfrage behalten, Antwort begrenzen

**Notizen:**

> 

## Vertretbare Schwächen – mit kurzer Einschränkung behalten

„Vertretbar“ bedeutet hier: kein offensichtlicher Grund für einen grundlegenden Umbau, wenn Aussage und Nachweisumfang zusammenpassen. Die tatsächliche Bewertung liegt bei den Prüfern.

| Thema | Empfehlung für diese Revision | Grenze, die nicht überschritten werden darf |
| --- | --- | --- |
| **Kleine Stichproben** (T11) | Behalten. N je Test korrekt nennen: betreffende Tests fünfmal, P1 dreimal, P2 zweimal funktional und einmal zeitlich auswertbar. | 100 % als beobachteten Anteil, nicht als allgemeine Zuverlässigkeit darstellen. |
| **Fehlende Median-/Streuungsangaben** (T11) | Wenn Rohdaten nicht verfügbar sind, nicht berichtete Kennzahlen auch nicht ankündigen. Sonst aus bestehenden Daten ergänzen, ohne neue Statistikstudie. | Einen nicht nachvollziehbaren Einzelwert nicht als überprüft ausgeben. Herkunft klären oder die Aussage entfernen. |
| **Manuelle Fehlerinjektion, GPS-Hot-Start, wechselnde Zyklusphase** | Behalten und knapp als Einschränkungen benennen. | Daraus keine präzise elektrische Fehlerlatenz oder allgemeine Genauigkeit ableiten. |
| **SIGSTOP und Kernel-Panic statt aller Hängerarten** (T12) | Behalten. Konkrete Injektion nennen; „Hänger“ als übergeordnete Motivation bleibt. | Keine vollständige Abdeckung von Teilhängern, Deadlocks oder Kernel-Fehlern behaupten. |
| **XOR und einzelne Parsertests** (T12) | Behalten. Keine CRC-Umstellung und keine neue Testkampagne. | Nur die geprüften Fälle als geprüft darstellen, keine vollständige Absicherung aller Rahmenzustände. |
| **P3-Unterspannung** (T13) | Als qualitative Zusatzuntersuchung behalten. Keine Verschiebung in den Anhang und keine Streichung des ganzen Versuchs erforderlich. | Keine bestimmten Resetursachen oder vollständige Recovery nach Spannungsrückkehr ohne Nachweis. Falls „MCU-Neustart“ nur aus Displayausfall vermutet wurde, diesen Teil korrigieren. |
| **Abstrakter globaler Automat und Hierarchie** (T09) | Grafiken und Grundidee behalten. Kurz erklären, dass es eine Abstraktion verschiedener Fehlerdomänen ist. | Keine universelle sequenzielle Reset-Kette behaupten. Unbelegte konkrete Retry-Grenzen/Übergänge müssen trotzdem korrigiert oder als Konzept gekennzeichnet werden. |
| **Keepalive / READY / Nutzfortschritt nicht vollständig beschrieben** (T08) | Falls Originalcode verfügbar ist, mit wenigen Zeilen erklären; ansonsten Nachweisgrenze benennen. Keine neue Überwachungslogik voraussetzen. | Die fehlende Beschreibung beweist keinen Programmfehler. Ein bekannter tatsächlicher Funktionsfehler wäre aber gesondert zu behandeln. |
| **Zwei einzeln atomare Zustandsdateien** (T14) | Architektur behalten. Ein Satz zur nicht automatisch garantierten gemeinsamen Datengeneration genügt zunächst. | Dateiatomizität nicht als Beweis fachlicher Konsistenz beider Dateien ausgeben. |
| **GPS-Hemisphärenregel** (T10) | Kleine Ergänzung: Formel beschreibt den Betrag; Süd/West erhalten ein negatives Vorzeichen. Gegen tatsächliche Auswertung prüfen. | Daraus nicht ohne Codeprüfung einen Fehler der Anwendung ableiten. |
| **Wiederholungen in Kapitel 5.2** (F05) | Bleiben. Keine größere Kapitelkürzung für dieses Revisionsziel. | Widersprüche zwischen wiederholten Aussagen müssen korrigiert werden. |
| **Versionsdetails und aktuelle Dokumentationslinks** | Für strittige technische Aussagen die nötigen Versionen klären; sonst keine vollständige Quellenüberarbeitung als Zusatzprojekt. | Unbekannte Versuchsversion nicht durch eine aktuelle Version ersetzen. |
| **Ein unzitierter Literatureintrag** | Nachrangig. Bei Gelegenheit tatsächliche Verwendung klären. | Keine künstliche Zitation ergänzen, nur damit der Eintrag verwendet erscheint. |

**Deine Ausnahmen / was du zusätzlich ändern möchtest:**

> 

## Was wir ausdrücklich nicht neu aufmachen

- Keine neue Richtung, kein neues Thema und keine neuen Forschungsfragen.
- Keine allgemeine neue Einordnung der Arbeit, die eine komplette Neufassung auslöst.
- Keine pauschale Streichung von H1, L1, P2 oder P3.
- Kein kontrollierter Strategievergleich, keine Langzeitstudie und keine größeren Stichproben als standardmäßiger nächster Schritt.
- Keine neuen Funktionen wie CRC, Bootloader-Rollback, Telemetrie oder gemeinsame Generationskennungen.
- Kein Austausch der nativen Diagramme nur für zusätzliche gestalterische oder konzeptionelle Perfektion.
- Keine vollständige Statistik-, Literatur- oder Kapitelüberarbeitung, wenn eine konkrete Einschränkung ausreicht.

**Ausnahme:** Wenn bei der Belegprüfung ein zentraler Befund nicht getragen wird oder ein tatsächlicher Funktionswiderspruch auftaucht, muss genau dieser Punkt entschieden werden. Eine Bestehensstrategie ist kein Grund, einen erkannten Fehler stehenzulassen.

## Minimales Arbeitspaket

1. **Kernbelege lokalisieren und ihre Verfügbarkeit klären.**
2. **P2:** Unbelegte Timeout-Erklärung entfernen; vorhandene Beobachtung präzise darstellen.
3. **L1/H1:** Messbedingungen überall eindeutig mitführen.
4. **Listing, GPS-Satz und verbleibende Satzabbrüche korrigieren.**
5. **F2 und Messvergleich begrenzen**, ohne Forschungsfrage oder Richtung zu ändern.
6. **Kurze Grenzen ergänzen:** Stichprobengrößen, konkrete Injektionen, P3 und abstrahierte Modelle. Dafür vorhandene Abschnitte nutzen.
7. **Zusammenfassung, Tabellen, Diagrammbeschriftungen und Fazit auf dieselben Aussagen bringen.**
8. **PDF und Verweise abschließend prüfen.**

## Wann ist dieses Paket erledigt?

- [ ] Keine klar falsche zentrale Messinterpretation mehr.
- [ ] Keine unbelegte Erklärung als gesicherte Tatsache dargestellt.
- [ ] Kernnachweise zugänglich oder verbleibende Beleglücken samt Folgen konkret behandelt.
- [ ] Kein widersprüchlicher GPS-Satz, fehlerhafter dargestellter Zeilenabschluss oder bedeutungsrelevanter Satzabbruch mehr.
- [ ] P2/L1/H1 und Stichprobengrößen in allen Teilen konsistent bezeichnet.
- [ ] Forschungsfragen und Richtung unverändert; nur die Stärke der Antworten an die Belege angepasst.
- [ ] Vertretbare Grenzen sind benannt und bleiben bestehen.
- [ ] Formale Abgabeanforderungen einschließlich erforderlicher Anhänge/Erklärungen separat geklärt.

Danach keine zusätzliche Optimierung aus diesem Plan ableiten. Ob noch weitere Änderungen für die konkrete Abgabe erforderlich sind, hängt von der Beleglage und den Anforderungen der Prüfer ab.

## Deine endgültigen Entscheidungen

**Diese Korrekturen machen wir:**

> 

**Diese Schwächen lassen wir mit Einschränkung stehen:**

> 

**Diese Belege kann ich liefern:**

> 
