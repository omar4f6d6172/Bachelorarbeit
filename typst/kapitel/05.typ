#import "../layout.typ": *

// Vorlage: PDF-Seite 37
= Evaluation <sec-5>

Dieses Kapitel untersucht, ob die im Rahmen der Arbeit implementierten Watchdog- und Recovery-Strategien unterschiedliche Fehlerzustände zuverlässig erkennen, eingrenzen und automatisch beheben. Betrachtet werden Fehler auf mehreren Ebenen: fehlerhafte Kommunikationsdaten, Ausfälle von Peripherie und externen Verbindungen, abgestürzte oder hängende Linux-Dienste, ein Stillstand der Mikrocontroller-Firmware, ein Kernel-Hänger, ein vollständiger Ausfall der Spannungsversorgung sowie kontrolliert abgesenkte Versorgungsspannungen. Das Ziel der Evaluation besteht nicht ausschließlich im Nachweis einer Fehlererkennung. Ein Test gilt erst dann als erfolgreich, wenn der zuvor definierte funktionale Endzustand wieder erreicht wurde. Dazu zählen je nach Testfall beispielsweise ein gültiger GPS-Fix, eine erfolgreiche Wetterabfrage, ein bestätigter UART-Datenrahmen, der Supervisor-Modus NORMAL oder ein automatisch wiederhergestelltes Gesamtsystem.

// Vorlage: PDF-Seite 37
== Zielsetzung und Evaluationsfragen <sec-5-1>

Die Evaluation beantwortet insbesondere folgende Fragen:

+ Werden die vorgesehenen Fehlerzustände zuverlässig erkannt?

+ Wird der Fehlerzustand korrekt an nachgelagerte Komponenten weitergegeben?

+ Wird die jeweils kleinstmögliche geeignete Recovery-Ebene verwendet?

+ Kehrt das System ohne manuellen Eingriff in einen funktionsfähigen Zustand zurück?

+ Wie lange dauern Fehlererkennung, Fehlerweitergabe und funktionale Wiederherstellung?

+ Wie reproduzierbar sind die gemessenen Zeiten über mehrere Versuchsdurchläufe?

// Vorlage: PDF-Seite 37
== Evaluationsaufbau und Beobachtungspunkte <sec-5-2>

Die Systemarchitektur, ihre Schnittstellen und die Recovery-Hierarchie wurden in #ref(<sec-3>, supplement: [Kapitel]) gemeinsam mit der Implementierung beschrieben. Für die Evaluation werden deshalb nur die konkrete Geräteauswahl, zusätzliche Messmittel und diejenigen Zustände ergänzt, an denen Fehlererkennung und funktionale Wiederherstellung beobachtet werden.

=== Hardware und externe Instrumentierung <sec-5-2-1>

Der Versuchsaufbau besteht aus einem Raspberry Pi 4 Model B, einem STM32-Nucleo-L432KC-Entwicklungsboard, einem unter der Vertriebsbezeichnung Binghe VK-162 erworbenen USB-GPS-Empfänger sowie einem LCD2004 mit AZDelivery-I2C-Adapter. Die intern erkannte GPS-Empfängereinheit meldete sich in den Versuchslogs als ublox-7- beziehungsweise UBX-G70xx-Hardware; die zugehörigen USB- und Startmeldungen sind in Anhang A dokumentiert. Aus den GPRMC-Datensätzen werden Breiten- und Längengrad bestimmt; GPRMC bezeichnet einen RMC-Satz mit dem NMEA-Talker-Identifier GP.

Der LCD-Adapter verwendet einen PCF8574-I/O-Expander \[#quelle(<lit-19>), S. 4\]; dessen technische Eigenschaften sind im NXP-Datenblatt dokumentiert \[#quelle(<lit-15>), S. 1 und 5–8\]. Für den ergänzenden Unterspannungstest wurde die NUCLEO-L432KC-Platine über VIN und GND von einem Labornetzteil versorgt und die eingestellte Spannung in 1-V-Schritten von 8 V bis 2 V abgesenkt. Beim Raspberry Pi wurde bei einer Sollspannung von 4,50 V zusätzlich vcgencmd get\_throttled abgefragt. Das Kommando liefert aktuelle und seit dem Start gespeicherte Unterspannungs- und Drosselungszustände als Bitmaske.

#include "../tabellen/tab-5-1.typ"

=== Softwareseitige Beobachtungspunkte <sec-5-2-2>

Die Evaluation greift auf dieselben Zustände zurück, die im Betrieb die Recovery steuern. Auf dem Raspberry Pi zeigen gps.json mit have_fix und fix_ts sowie weather.json mit ok und reason die Verfügbarkeit und Aktualität der beiden Eingangszustände. Der Status in weather.json beschreibt jedoch nur den Erfolg des Wetterabrufs; ein unabhängiger Zustand der allgemeinen Netzwerkkonnektivität wird im Prototyp nicht erfasst. Das systemd-Journal dokumentiert Prozessstarts, Watchdog-Timeouts und Dienstneustarts. An der Plattformgrenze belegen PONG, OK und die Fehlermeldungen des UART-Protokolls, ob Nachrichten empfangen, validiert und beantwortet wurden.

Auf dem STM32 markieren APP_RUNTIME, die Supervisor-Zustände und die Reset-Ursache den Übergang vom Boot zur funktionsfähigen Anwendung. LCD_DRIVER, RPI_LINK und die kumulativen Fehler- und Recovery-Zähler grenzen lokale Peripheriefehler von Kommunikations- und Firmwarefehlern ab. Die in #ref(<sec-3-7>, supplement: [Abschnitt]) definierte Eskalationshierarchie legt für jeden Testfall die erwartete Reaktion fest; der Testkatalog in #ref(<sec-5-4>, supplement: [Abschnitt]) ordnet diesen Reaktionen die konkrete Fehlerinjektion und das jeweilige Erfolgskriterium zu.

// Vorlage: PDF-Seite 40
== Messmethodik <sec-5-3>

// Vorlage: PDF-Seite 40
=== Messgrößen <sec-5-3-1>

Die gezielte Fehlerinjektion ist ein etabliertes Mittel zur experimentellen Bewertung von Fehlererkennungs- und Recovery-Mechanismen \[#quelle(<lit-22>), S. 75–76\]. Für jeden Testfall wurden mindestens zwei Zeitpunkte betrachtet: der Beginn der Fehlerinjektion und das Erreichen eines definierten funktionalen Endzustands. Abhängig vom Testfall wurden zusätzlich Zwischenzeitpunkte protokolliert: Fehlerinjektionszeitpunkt: Zeitpunkt, zu dem der Fehler ausgelöst oder durch den Bediener bestätigt wurde. Fehlererkennungszeitpunkt: Zeitpunkt, zu dem der zuständige Dienst oder Supervisor den Fehler registrierte. Fehlerweitergabezeitpunkt: Zeitpunkt, zu dem der Fehlerstatus an eine nachgelagerte Komponente übertragen wurde. Recovery-Zeitpunkt: Zeitpunkt, zu dem die zuvor ausgefallene Teilfunktion erneut verfügbar war. Funktionale Wiederherstellung: Zeitpunkt, zu dem der vollständige Datenpfad wieder funktionierte und das Ergebnis bestätigt wurde. Die allgemeine End-to-End-Zeit ergibt sich aus

#gleichung($t_"E2E" = t_"funktional" - t_"Fehler"$, <eq-5-1>)

Dabei bezeichnet $t_"Fehler"$ den für den jeweiligen Testfall festgelegten Startzeitpunkt. Dieser ist je nach Versuch die automatische Fehlerinjektion, eine Bedienerbestätigung oder das erste externe DOWN-Ereignis. $t_"funktional"$ ist der Zeitstempel, an dem der vorab definierte funktionale Endzustand bestätigt wurde. Die konkreten Start- und Endereignisse werden je Testfall angegeben.

// Vorlage: PDF-Seite 41
=== Monotone Zeitquelle und Journal-Cursor <sec-5-3-2>

Für Zeitdifferenzen innerhalb eines laufenden Linux-Systems wurde überwiegend time.monotonic() verwendet \[#quelle(<lit-23>), Abschn. time.monotonic()\]. Diese Zeitquelle ist gegen nachträgliche Änderungen der Systemzeit unempfindlich. Vor jeder Fehlerinjektion wurde außerdem ein systemd-Journal-Cursor gespeichert. Für die Auswertung wurden ausschließlich Logeinträge nach diesem Cursor berücksichtigt. Dadurch konnten ältere Meldungen nicht fälschlich einem aktuellen Versuch zugeordnet werden. Zu den ausgewerteten Meldungen gehörten unter anderem:

```text
INTERNET_ERROR
STM32_CONNECTION_ERROR
STM32: PONG
STM32: OK
Watchdog timeout
Failed with result 'watchdog'
RPI_LINK_RECOVERED
```

Die implementierte Meldung INTERNET_ERROR ist dabei ein Sammelbezeichner für einen fehlgeschlagenen Wetterabruf. Sie identifiziert weder einen allgemeinen Netzwerkausfall noch einen Fehler des Wetterdienstes eindeutig.

// Vorlage: PDF-Seite 41
=== Externe Messung bei vollständigen Neustarts <sec-5-3-3>

Bei einem vollständigen Neustart kann ein lokal laufendes Messprogramm die Messung nicht fortsetzen. Deshalb wurde sowohl für P1, den vollständigen Spannungsverlust des Gesamtsystems, als auch für P2, die gezielt ausgelöste Kernel-Panic des Raspberry Pi, ein externer Rechner verwendet. Dieser prüfte die Erreichbarkeit des Raspberry Pi in Intervallen von 0,25 s per ICMP-Ping und protokollierte die Zustandswechsel UP, DOWN und erneut UP. Die externe Nichtverfügbarkeit wurde berechnet als

#gleichung($t_"extern" = t_"UP" - t_"DOWN"$, <eq-5-2>)

Dabei ist $t_"DOWN"$ der Zeitstempel des ersten als nicht erreichbar protokollierten Zustands und $t_"UP"$ der Zeitstempel der erneut bestätigten Erreichbarkeit. Diese Zeit enthält je nach Testfall die verbleibende Watchdog-Zeit, den Reset, den Bootvorgang und die Wiederherstellung der Netzwerkschnittstelle.

// Vorlage: PDF-Seite 42
=== Manuell ausgelöste Hardwarefehler <sec-5-3-4>

Die drei manuell injizierten Hardwarefehler werden bereits an dieser Stelle eingeführt: G1 bezeichnet das Entfernen und erneute Anschließen des USB-GPS-Empfängers. Bei C1 wird die UART-Sendeleitung vom Raspberry Pi zum STM32 getrennt und wiederverbunden. L1 bezeichnet die Trennung und Wiederverbindung der SDA-Leitung im LCD-/I2C-Pfad. Der vollständige Testkatalog mit erwartetem Verhalten und Erfolgskriterien folgt in #ref(<sec-5-4>, supplement: [Abschnitt]). Da die Eingriffe manuell erfolgten, beginnt die Zeitmessung teilweise mit einer Bedienerbestätigung und nicht mit dem exakten elektrischen Umschaltzeitpunkt.

// Vorlage: PDF-Seite 42
=== Wiederholungen und statistische Kenngrößen <sec-5-3-5>

Die risikoarmen und reproduzierbaren Tests wurden jeweils fünfmal durchgeführt. Der vollständige Spannungsverlust wurde aufgrund der zusätzlichen Belastung des Dateisystems dreimal getestet. Der Kernel-Hänger wurde zweimal ausgeführt; eine gültige externe Zeitmessung liegt für den zweiten Durchlauf vor. Für die wiederholten Tests wurden Erfolgsrate, Mittelwert, Median, Minimum, Maximum und Stichproben-Standardabweichung bestimmt. Die Erfolgsrate lautet

#gleichung($p_"Erfolg" = frac(n_"erfolgreich", n_"gesamt") dot 100 %$, <eq-5-3>)

$n_"erfolgreich"$ ist die Anzahl der Durchläufe, die das festgelegte Erfolgskriterium erfüllen; $n_"gesamt"$ bezeichnet alle ausgeführten Durchläufe des betreffenden Testfalls.

// Vorlage: PDF-Seite 42
=== Dokumentation und Datenintegrität <sec-5-3-6>

Für jeden Durchlauf wurden Logdateien, Zustandsdateien und CSV-Messwerte in einem separaten Verzeichnis gespeichert. Nach Abschluss der Evaluation wurde das vollständige Verzeichnis archiviert. Der SHA-256-Prüfwert identifiziert genau den unveränderten Inhalt dieser Archivdatei; er ersetzt jedoch nicht deren Bereitstellung. Der Prüfwert des finalen Archivs lautet:

```text
2e5134c401f3308dd6acbd33e57b0e516af9fa5dfe1a8a47ef6e2a3b633b5bc4
```

// Vorlage: PDF-Seite 42
== Definition der Testfälle <sec-5-4>

Die Testfallkennungen dienen als stabile Referenzen; ihr Buchstabe gruppiert die untersuchte Domäne: N bezeichnet hier den externen HTTPS-Wetterdatenpfad, G das GPS, C die Verbindung zwischen Raspberry Pi und STM32, H den Firmware-Hänger, S Linux-Dienste, U das UART-Protokoll, L den LCD-/I2C-Pfad und P systemweite Versorgungs- oder Plattformtests. Die Kennung N legt keine Ursache innerhalb des Wetterdatenpfads fest. Die Ziffer ist lediglich eine laufende Kennung innerhalb des Testkatalogs und beschreibt weder Schweregrad noch Ausführungsreihenfolge.

Für die Fehlerinjektion bezeichnet nftables den Linux-Paketfilter, mit dem ausgehende HTTPS-Verbindungen blockiert werden. Das Signal SIGSTOP pausiert einen Prozess, ohne ihn zu beenden, und modelliert hier einen Hänger; SIGKILL beendet ihn unmittelbar und modelliert einen Absturz. Magic SysRq ist eine Kernel-Schnittstelle, über die im Test gezielt eine Kernel-Panic ausgelöst wird. Ein Power-Cycle ist das vollständige Trennen und anschließende Wiederherstellen der Versorgung.

#include "../tabellen/tab-5-2.typ"

Hinweis zu N2: Der Test blockiert gezielt ausgehende TCP-Verbindungen zu Port 443 und damit den HTTPS-Pfad der Wetterabfrage. Er prüft die Reaktion auf einen nicht verfügbaren Wetterdatenpfad. Der Versuch trennt weder einen lokalen beziehungsweise allgemeinen Netzwerkfehler von einem Fehler des Wetterdienstes noch untersucht er HTTP-Fehler oder ungültige API-Antworten. Entsprechend darf N2 nicht als Nachweis einer ursachenspezifischen Netzwerkdiagnose interpretiert werden.

Ergänzend zum ursprünglichen Katalog wurde der Testfall P3 aufgenommen. P3a charakterisiert das Unterspannungsverhalten der NUCLEO-L432KC-Platine mit angeschlossenem LCD bei schrittweise abgesenkter VIN-Spannung; der qualitative Ablauf wurde fünfmal wiederholt. P3b dokumentiert beim Raspberry Pi den Statuswert von vcgencmd get\_throttled bei einer am Labornetzteil eingestellten Spannung von 4,50 V.

// Vorlage: PDF-Seite 45
== Messergebnisse <sec-5-5>

// Vorlage: PDF-Seite 45
=== Gesamtübersicht <sec-5-5-1>

Alle wiederholten funktionalen Recovery-Testfälle erreichten eine Erfolgsrate von 100 %. #ref(<tab-5-3>, supplement: [Tabelle]) fasst die wichtigsten End-to-End-Messgrößen dieser Testfälle zusammen. Bei U1, U2 und L1 liegen die Zeiten im Millisekundenbereich. Die manuell ausgelösten Tests G1, C1 und L1 besitzen die in #ref(<sec-5-3>, supplement: [Abschnitt]) beschriebenen Einschränkungen. Der ergänzende Unterspannungstest P3 wird separat ausgewertet, da er ein qualitatives Platinenverhalten und keine End-to-End-Recovery-Zeit beschreibt.

#include "../tabellen/tab-5-3.typ"

Für P2 wurden zwei funktional erfolgreiche Durchläufe ausgeführt. Eine verwertbare externe Zeitmessung liegt jedoch nur für Durchlauf 02 vor. Der Wert von 35 s ist deshalb ein Einzelwert und kein Mittelwert; Streuungsmaße werden für P2 nicht angegeben.

// Vorlage: PDF-Seite 47
=== N2: Blockierung und Wiederherstellung des HTTPS-Wetterdatenpfads <sec-5-5-2>

Zum Auslösen der Störung blockierte eine nftables-Regel ausgehende TCP-Verbindungen zu Port 443. Jeder der fünf Durchläufe führte erwartungsgemäß zum protokollierten Sammelzustand NET=ERR; weder der Wetterabruf- noch der UART-Dienst musste dafür neu gestartet werden. Zwischen Aktivierung der Regel und INTERNET\_ERROR lagen im Mittel 3,14 s. Bis der STM32 den Fehlerstatus erhielt, kamen durchschnittlich 4,22 s hinzu. Die End-to-End-Fehlerweitergabe dauerte damit im Mittel 7,36 s. Nach Aufhebung der Sperre lieferte die Wetterabfrage nach durchschnittlich 5,82 s wieder gültige Daten. Weitere 4,28 s später war NET=OK an den STM32 übertragen. Für die vollständige funktionale Wiederherstellung ergibt sich ein Mittelwert von 10,10 s. Die Standardabweichung von lediglich 0,14 s weist darauf hin, dass dieser Ablauf vor allem durch die periodischen Dienstzyklen bestimmt wird. Aufgrund des Sammelstatus lässt sich aus diesen Messungen nicht ableiten, ob der Prototyp einen Netzwerkausfall von einem Fehler des Wetterdienstes unterscheiden könnte.

// Vorlage: PDF-Seite 47
=== G1: Verlust und Wiederkehr des GPS-Empfängers <sec-5-5-3>

Nach dem Trennen des USB-GPS setzte der GPS-Dienst den booleschen Status have\_fix auf false. Der UART-Dienst kennzeichnete die Daten daraufhin mit GPS=ERR und MODE=LAST. Vom erkannten Geräteverlust bis zu dieser Weitergabe vergingen durchschnittlich 3,12 s. Nach dem Wiederanschluss stand ein gültiger Fix im Mittel nach 4,22 s zur Verfügung; die Umschaltung auf MODE=LIVE folgte nach weiteren 2,20 s. Insgesamt dauerte die funktionale Wiederherstellung im Mittel 6,42 s. Die Einzelwerte streuen deutlich. Ursachen sind die manuelle Fehlerinjektion, die jeweilige Phase der periodischen Dienstzyklen und der Hot-Start des GPS-Empfängers, bei dem noch gespeicherte Zeit- und Bahndaten die erneute Positionsbestimmung beschleunigen können.

// Vorlage: PDF-Seite 47
=== C1: Unterbrechung der Verbindung zum STM32 <sec-5-5-4>

Für C1 wurde die Sendeleitung des Raspberry Pi zum STM32 manuell getrennt. Alle fünf Unterbrechungen führten zu einer Verbindungsfehlermeldung. Ab der Bedienerbestätigung wurden dafür durchschnittlich 3,80 s benötigt. Nach dem Wiederverbinden traf das erste erfolgreiche PONG im Mittel nach 4,68 s ein. Der anschließend gesendete Wetterrahmen wurde bereits nach weiteren 0,05 s bestätigt. Die Gesamtzeiten lagen zwischen 0,13 s und 13,30 s. Fast die gesamte Streuung entstand vor dem ersten PONG, also durch die zeitliche Lage der Wiederverbindung innerhalb des Retry-Zyklus. Sobald der Heartbeat wieder funktionierte, verlief die Datenübertragung dagegen nahezu konstant.

// Vorlage: PDF-Seite 48
=== H1: Firmware-Hänger und STM32-IWDG <sec-5-5-5>

Mit HANG wurde die Firmware gezielt angehalten; zuvor bestätigte der STM32 den Befehl durch HANGING. Das Boot-Banner erschien im Mittel 1,23 s später, ein PONG während der Bootdiagnose nach 3,35 s. Vom Absenden des HANG-Befehls bis zum erneuten Applikationsbetrieb vergingen jeweils 5,70 s. Die Diagnose meldete in sämtlichen Durchläufen den IWDG als Reset-Ursache. Nach dem Wechsel in den Applikationsmodus funktionierte auch die PING/PONG-Kommunikation wieder. Dass die gerundeten Werte in allen fünf Messungen übereinstimmen, belegt die Reproduzierbarkeit innerhalb der Auflösung von 0,01 s.

// Vorlage: PDF-Seite 48
=== S1 und S2: Hängender gegenüber abgestürztem GPS-Dienst <sec-5-5-6>

Der direkte Vergleich von S1 und S2 macht den Einfluss der Fehlerart sichtbar. Im Hängerfall existierte der Prozess weiter, lieferte jedoch keine Keepalive-Nachrichten. Systemd konnte erst nach Ablauf des Service-Watchdog-Timeouts reagieren; bis zur wiederhergestellten GPS-Funktion vergingen im Mittel 28,46 s. Nach SIGKILL war das Prozessende dagegen sofort erkennbar. Der Service-Manager musste nur die konfigurierte Neustartverzögerung abwarten und den neuen Prozess starten. Die funktionale Wiederherstellung dauerte deshalb im Mittel lediglich 5,76 s. Gegenüber dem Hänger verkürzte sich die Ausfallzeit um 22,70 s, also ungefähr um den Faktor 4,9.

#vorlage("abb-5-1.png", "Vergleich der mittleren funktionalen Wiederherstellungszeiten")

// Vorlage: PDF-Seite 48
=== S3: Hänger des UART-Dienstes <sec-5-5-7>

Auch den angehaltenen UART-Dienst erkannte der systemd-Service-Watchdog in jedem Durchlauf. Bis zum Neustart vergingen durchschnittlich 33,22 s. Danach war die serielle Kommunikation nahezu unmittelbar verfügbar: Das erste PONG traf nach 0,04 s ein, die Bestätigung des Wetterrahmens nach weiteren 0,08 s. Daraus ergibt sich eine mittlere funktionale Wiederherstellungszeit von 33,34 s. Zusätzlich protokollierte der STM32 bei allen fünf Versuchen RPI\_LINK\_RECOVERED. Damit ist nicht nur der Neustart des Linux-Dienstes, sondern auch die erneute Funktionsfähigkeit des vollständigen Kommunikationspfads nachgewiesen.

// Vorlage: PDF-Seite 50
=== U1 und U2: UART-Datenintegrität und Puffergrenzen <sec-5-5-8>

U1 bestätigte die Prüfsummenprüfung: Sämtliche fünf Rahmen mit bewusst falschem XOR-Wert wurden verworfen. Bis zur Antwort ERR:CHECKSUM vergingen durchschnittlich 0,010 s. Direkt danach akzeptierte der STM32 jeweils einen gültigen Rahmen und beantwortete auch den folgenden PING. Für U2 wurden Zeilen mit 140 Zeichen gesendet und damit die festgelegte Puffergrenze überschritten. Jeder Versuch erzeugte ERR:BUFFER; die Antwort erfolgte im Mittel nach 0,018 s. Anschließend blieben sowohl PING/PONG als auch die Verarbeitung eines gültigen Datenrahmens funktionsfähig. Die Fehlerbehandlung verwirft somit den betroffenen Rahmen, ohne den Empfänger dauerhaft zu desynchronisieren oder einen Reset auszulösen.

// Vorlage: PDF-Seite 50
=== L1: Lokale Recovery des LCD-/I2C-Pfads <sec-5-5-9>

Das Trennen der SDA-Leitung führte in jedem Versuch zum Übergang von NORMAL nach DEGRADED; gleichzeitig änderte sich LCD\_DRIVER von OK auf FAIL. Nach dem Wiederanschluss kehrte der Supervisor ohne Mikrocontroller-Reset in den Normalzustand zurück. Ab der Bedienerbestätigung lagen zwischen Eingriff und bestätigtem Supervisor-Zustand im Mittel 0,046 s für den Fehler sowie 0,044 s für die Recovery.

// Vorlage: PDF-Seite 50
=== P1: Vollständiger Spannungsverlust <sec-5-5-10>

Der vollständige Spannungsverlust wurde in drei Durchläufen untersucht. Die externe Netzwerküberwachung erfasste Ausfallzeiten von 33 s, 32 s und 32 s. Der Mittelwert beträgt 32,33 s.

#include "../tabellen/tab-5-4.typ"

Bei jedem Durchlauf änderte sich die Boot-ID, die eine einzelne Linux-Boot-Sitzung eindeutig kennzeichnet; anschließend starteten alle drei Dienste automatisch. GPS-Fix, Wetterabfrage und STM32-Kommunikation wurden ohne manuellen Eingriff wiederhergestellt. Für P1-02 und P1-03 konnten zusätzlich konsistente interne Boot-Messungen ausgewertet werden. Die vollständige Anwendungsbereitschaft lag bei 21,401 s und 21,102 s nach Beginn des Linux-Bootvorgangs. Der Mittelwert der beiden gültigen internen Messungen beträgt 21,252 s. Beim ersten Lauf war die interne Zeitmessung aufgrund einer nachträglichen Korrektur der Systemzeit nicht auswertbar. Die externe Messung blieb davon unbeeinflusst. Nach den abrupten Abschaltungen führte ext4 eine automatische Bereinigung verwaister Dateisystemeinträge durch; schwerwiegende I/O- oder Dateisystemfehler wurden nicht beobachtet.

#vorlage("abb-5-2.png", "Extern gemessene Ausfallzeiten der drei P1-Durchläufe")

// Vorlage: PDF-Seite 51
=== P2: Kernel-Hänger und Hardware-Watchdog <sec-5-5-11>

Der Raspberry Pi betrieb den BCM2835-Hardware-Watchdog mit einem von wdctl gemeldeten Timeout von 60 s. Der Fehler wurde als Kernel-Panic über Magic SysRq ausgelöst. Da kernel.panic=0 einen automatischen Neustart des Kernels ausschloss, blieb als vorgesehener Recovery-Pfad nur der unabhängige Hardware-Watchdog.

Beide Durchläufe waren funktional erfolgreich: Die Boot-ID änderte sich, alle drei Dienste starteten erneut, und GPS, Wetterabfrage sowie STM32-Kommunikation standen wieder zur Verfügung. Für die zeitliche Auswertung liegt jedoch nur ein verwertbarer Durchlauf vor: Einzelmessung: 35 s; Der von wdctl gemeldete Watchdog-Timeout von 60 s beginnt nicht mit dem ersten fehlgeschlagenen externen Ping. Der Hardware-Watchdog wurde bereits vor der Fehlerinjektion periodisch aktualisiert; beim Auslösen der Kernel-Panic konnte deshalb ein Teil des aktuellen Watchdog-Intervalls bereits verstrichen sein. Die externe Messung setzte zudem erst beim Übergang von Netzwerkzustand UP zu DOWN ein. Der Einzelwert umfasst somit die verbleibende Watchdog-Zeit, den Hardware-Reset, den Linux-Boot und die Wiederherstellung der Netzwerkverbindung.

// Vorlage: PDF-Seite 52
=== P3: Kontrollierter Unterspannungstest <sec-5-5-12>

*NUCLEO-L432KC mit LCD*

Die NUCLEO-L432KC-Platine wurde über VIN und GND mit dem Labornetzteil versorgt. Nach Herstellerangabe ist für VIN ein Eingangsbereich von 7 V bis 12 V vorgesehen \[#quelle(<lit-24>), Abschn. 7.4 und Tab. 5\]. Die Werte unterhalb von 7 V lagen damit gezielt außerhalb des spezifizierten Betriebsbereichs. Die Spannung wurde in 1-V-Schritten von 8 V auf 2 V abgesenkt. Der vollständige Ablauf wurde fünfmal wiederholt; in allen fünf Durchläufen wurde dasselbe qualitative Verhalten beobachtet.

#vorlage("abb-5-3.png", "Qualitative Degradationsstufen in Abhängigkeit von der am Labornetzteil eingestellten VIN-Spannung")

#ref(<abb-5-3>, supplement: [Abbildung]) stellt die beobachtete Degradationsfolge auf zwei Achsen dar. Auf der x-Achse steht die am Labornetzteil eingestellte VIN-Spannung. Für die y-Achse wurden die qualitativen Beobachtungen in fünf ordinal geordnete Zustandsklassen überführt. Die Abstände zwischen diesen Klassen besitzen keine metrische Bedeutung.

Die Beschriftung „5/5“ kennzeichnet, dass der jeweilige Zustand in allen fünf Durchläufen beobachtet wurde.

#echtetabelle("Reproduzierbares Unterspannungsverhalten der NUCLEO-L432KC-Platine", key: <tab-5-5>, (0.6fr, 4fr, 0.8fr), ([VIN], [Beobachtung], [Durchläufe],), (
  [8–6 V],
  [STM32 und LCD arbeiteten ohne sichtbare Einschränkungen; Zeichen und Hintergrundbeleuchtung waren normal.],
  [5/5],
  [5 V],
  [Die Zeichen blieben sichtbar; die Hintergrundbeleuchtung wurde erkennbar schwächer.],
  [5/5],
  [4 V],
  [Die Hintergrundbeleuchtung blieb aktiv, Zeichen wurden nicht mehr dargestellt; gleichzeitig wurde ein STM32-Neustart beobachtet.],
  [5/5],
  [3 V],
  [Ein weiterer STM32-Neustart wurde beobachtet; das LCD einschließlich Hintergrundbeleuchtung war vollständig aus.],
  [5/5],
  [2 V],
  [Der STM32 stellte den Betrieb vollständig ein.],
  [5/5],
))

Die Beobachtungen zeigen keinen abrupten Übergang von vollständiger Funktion zu vollständigem Ausfall, sondern eine reproduzierbare Degradationsfolge: zunächst verringerte sich die Helligkeit, anschließend fiel die Zeichendarstellung aus, danach traten Neustarts und schließlich der vollständige Stillstand ein. Ein solcher Bereich zwischen normaler Funktion und Abschaltung entspricht konzeptionell der in der Literatur beschriebenen Unterspannungszone, in der Komponenten bereits unzuverlässig arbeiten können \[#quelle(<lit-26>), S. 15–16\].

*Raspberry Pi bei 4,50 V*

Beim Raspberry Pi wurde bei einer am Labornetzteil eingestellten Spannung von 4,50 V in Abständen von 0,5 s vcgencmd get\_throttled aufgerufen. Die erfasste Ausgabe lautete throttled=0x50005.

#vorlage("abb-5-4.png", "Raspberry-Pi-Status bei 4,50 V: throttled=0x50005")

Nach der offiziellen Raspberry-Pi-Dokumentation stehen die gesetzten Bits 0 und 2 für aktuell erkannte Unterspannung und aktuell aktive Drosselung; die Bits 16 und 18 speichern, dass beide Zustände seit dem letzten Start bereits aufgetreten sind \[#quelle(<lit-25>), Abschn. “get\_throttled”\]. Die Messung belegt damit eine zum Aufnahmezeitpunkt aktive Unterspannung und Drosselung.

// Vorlage: PDF-Seite 54
== Zusammenfassung der Messergebnisse <sec-5-6>

Innerhalb der beschriebenen Versuchsbedingungen wurden alle fünfmal wiederholten funktionalen Recovery-Testfälle erfolgreich abgeschlossen. Die zentralen Einzel- und Aggregatwerte sind in #ref(<tab-5-3>, supplement: [Tabelle]) zusammengefasst. Für P1 lag die mittlere externe Netzwerknichtverfügbarkeit bei 32,33 s; für P2 liegt ausschließlich die oben ausgewiesene Einzelmessung von 35 s vor. P3 zeigte in fünf von fünf STM32-Durchläufen dieselbe stufenweise Degradation; die Raspberry-Pi-Messung belegte bei 4,50 V eine aktive Unterspannung und Drosselung. Die Interpretation der Unterschiede, die Beantwortung der Forschungsfragen und die Grenzen der Übertragbarkeit folgen in #ref(<sec-6>, supplement: [Kapitel]).
