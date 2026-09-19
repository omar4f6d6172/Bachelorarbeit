#import "../layout.typ": *

// Vorlage: PDF-Seite 20
= Anforderungen und Systemkonzept <sec-3>

// Vorlage: PDF-Seite 20
== Anwendungsfall als Testumgebung <sec-3-1>

Als Testumgebung wird ein eingebettetes System verwendet, das seine Position über einen Binghe VK-162 USB-GPS-Empfänger bestimmt, Wetterdaten für diese Position von einem externen Dienst abruft und die Informationen auf einem LCD darstellt. Der Raspberry Pi übernimmt netzwerk- und betriebssystemnahe Aufgaben. Der STM32 übernimmt die hardwarenahe Displaysteuerung und eine unabhängige Überwachung der Mikrocontroller-Firmware. Der Datenfluss umfasst GPS-Erfassung, Wetterabfrage, UART-Übertragung und Anzeige. Die Fehlerdomänen und Schnittstellen sind in #ref(<abb-3-1>, supplement: [Abbildung]) dargestellt.

#vorlage("abb-3-1.png", "Gesamtarchitektur und wesentliche Datenpfade des Versuchssystems")

Der Anwendungsfall wurde gewählt, weil er mehrere voneinander unabhängige Fehlerquellen in einem überschaubaren Aufbau vereint. Die wissenschaftliche Fragestellung betrifft nicht das Anzeigen von Wetterdaten, sondern die Überwachung und Wiederherstellung des vollständigen Datenpfads.

// Vorlage: PDF-Seite 21
== Funktionale Anforderungen <sec-3-2>

#include "../tabellen/tab-3-1.typ"

// Vorlage: PDF-Seite 21
== Nichtfunktionale Anforderungen <sec-3-3>

#include "../tabellen/tab-3-2.typ"

// Vorlage: PDF-Seite 22
== Fehlermodell <sec-3-4>

Das Fehlermodell umfasst Fehler auf Daten-, Komponenten-, Prozess-, Firmware- und Systemebene. Für jede Fehlerklasse werden Erkennung und Recovery bereits im Systementwurf festgelegt.

#include "../tabellen/tab-3-3.typ"

Hinweis zur externen Kommunikation: Allgemeine Netzwerkkonnektivität und Verfügbarkeit des Wetterdienstes sind unterschiedliche Fehlerquellen. Die aktuelle Implementierung fasst beide für den Wetterdatenpfad noch zu einem gemeinsamen Fehlerzustand zusammen; die Konsequenz wird in #ref(<sec-4-2-4>, supplement: [Abschnitt]) erläutert.

// Vorlage: PDF-Seite 23
== Systemarchitektur <sec-3-5>

// Vorlage: PDF-Seite 23
=== Aufgabenteilung <sec-3-5-1>

Die Gesamtarchitektur folgt dem Datenpfad GPS -\> Wetterabfrage -\> UART -\> LCD (#ref(<abb-3-1>, supplement: [Abbildung])). Der Raspberry Pi übernimmt GPS-Verarbeitung, externe Kommunikation und Prozessüberwachung; der STM32 übernimmt UART-Validierung, Anzeige und hardwarenahe Überwachung. Die UART-Verbindung bildet die Plattformgrenze. Die folgenden Abschnitte beschreiben die Ebenen in derselben Reihenfolge wie der Datenpfad; Komponentengrenzen werden dabei zugleich als Fehler- und Recovery-Grenzen betrachtet.

#include "../tabellen/tab-3-4.typ"

// Vorlage: PDF-Seite 23
=== Dienstarchitektur auf dem Raspberry Pi <sec-3-5-2>

Auf dem Raspberry Pi bildet weather-gps.service die Eingangsseite des Datenpfads und schreibt den Positionszustand nach /dev/shm/weather/gps.json. weather-net.service liest diesen Zustand und erzeugt daraus den Wetterzustand in weather.json. weather-uart.service liest beide Zustände, bildet den seriellen Datenrahmen und besitzt exklusiv /dev/serial0. Die Zustandsdateien entkoppeln die Prozesse; ein Fehler eines Dienstes soll deshalb die übrigen Pfade nicht unnötig zurücksetzen. #ref(<abb-3-2>, supplement: [Abbildung]) zeigt diesen gerichteten Datenfluss und die zugehörigen Dienstgrenzen.

#vorlage("abb-3-2.png", "Entkopplung der Raspberry-Pi-Dienste über atomar aktualisierte Zustandsdateien")

// Vorlage: PDF-Seite 23
=== Architektur auf dem STM32 <sec-3-5-3>

Die STM32-Firmware bildet die Ausgangs- und Überwachungsebene des Datenpfads. Sie umfasst Bootdiagnose, UART-Protokollverarbeitung, LCD-Treiber und Supervisor. Der Supervisor verwaltet die Subsysteme BOOT, MAIN\_LOOP, UART\_DRIVER, LCD\_DRIVER, RPI\_LINK und POWER\_SUPPLY. Für jedes Subsystem werden Zustand, Kritikalität und Alter des letzten erfolgreichen Lebenszeichens betrachtet. Ein nicht kritischer LCD-Fehler führt zum Modus DEGRADED, während Hauptfunktion und UART-Verbindung weiterlaufen können. Ein Stillstand der Hauptschleife verhindert dagegen die Freigabe des IWDG-Refresh und führt zu einem Reset. Damit bildet der STM32 die lokale Recovery-Ebene unterhalb der Raspberry-Pi-Dienste. Der Datenfluss in #ref(<abb-3-2>, supplement: [Abbildung]) verbindet die drei Dienstgrenzen zu einer Kette: Position, Wetterzustand und serieller Rahmen werden nacheinander erzeugt. Die UART-Schnittstelle bildet anschließend den Übergang zur STM32-Ebene. Dadurch bleibt die Zuordnung von Datenpfad, Fehlerdomäne und Recovery-Ebene über beide Plattformen hinweg nachvollziehbar.

// Vorlage: PDF-Seite 24
== Konzept der UART-Verbindung <sec-3-6>

// Vorlage: PDF-Seite 24
=== Heartbeat <sec-3-6-1>

Der Raspberry Pi sendet periodisch PING. Der STM32 antwortet mit PONG. Dadurch wird nicht nur geprüft, ob die UART-Schnittstelle offen ist, sondern ob die Firmware den Datenrahmen empfangen, verarbeiten und eine Antwort erzeugen kann.

// Vorlage: PDF-Seite 24
=== Datenrahmen <sec-3-6-2>

Ein Wetterdatenrahmen besitzt grundsätzlich folgende Form:

```text
GPS=OK;NET=OK;TEMP=19.3;WIND=10.2;CODE=3;MODE=LIVE*XX
```

Die Nutzdaten werden durch Schlüssel-Wert-Paare beschrieben. Nach dem Sternzeichen folgt eine hexadezimal dargestellte XOR-Prüfsumme. Der STM32 akzeptiert einen Rahmen erst nach erfolgreicher Prüfung. Ein ungültiger Rahmen wird mit ERR:CHECKSUM abgelehnt. Bei Überschreitung des Empfangspuffers wird ERR:BUFFER zurückgegeben.

// Vorlage: PDF-Seite 24
=== Betriebsmodi <sec-3-6-3>

MODE=LIVE kennzeichnet aktuelle Daten auf Grundlage eines gültigen GPS-Fix. Bei Verlust des GPS-Empfangs bleiben zuletzt bekannte Daten verfügbar und werden mit MODE=LAST sowie GPS=ERR gekennzeichnet. Dadurch bleibt der Systemzustand transparent; veraltete Daten werden nicht als aktuelle Daten dargestellt.

// Vorlage: PDF-Seite 25
== Hierarchisches Watchdog- und Recovery-Konzept <sec-3-7>

Das Recovery-Konzept ist als Eskalationshierarchie aufgebaut:

Ebene 1: Datenrahmen verwerfen: ungültige Prüfsumme oder zu langer Rahmen.

Ebene 2: Lokale Komponente reinitialisieren: LCD-/I2C-Fehler.

Ebene 3: Degradierter Betrieb und Retry: GPS- oder Netzwerkfehler.

Ebene 4: Einzelnen Dienst neu starten: Prozessabsturz oder Service-Watchdog-Timeout.

Ebene 5: Mikrocontroller zurücksetzen: Firmware-Hänger des STM32.

Ebene 6: Raspberry Pi neu starten: Kernel-Hänger oder vollständiger Systemfehler.

#vorlage("abb-3-3.png", "Eskalationshierarchie der Recovery-Strategien")

Diese Reihenfolge minimiert die Eingriffstiefe. Ein nicht kritischer Fehler soll nicht zum Verlust funktionierender Zustände führen. Erst wenn eine lokale Behandlung nicht ausreicht, wird auf eine tiefere Recovery-Ebene eskaliert.

// Vorlage: PDF-Seite 25
== Systemweiter Recovery-Zustandsautomat <sec-3-8>

Der globale Systemzustand unterscheidet zwischen stabilen Betriebszuständen und transienten Recovery-Zuständen. Der in #ref(<abb-3-4>, supplement: [Abbildung]) dargestellte Automat ist eine systemweite Abstraktion der verteilten Implementierung. Er ist nicht als zusätzliche monolithische Softwarekomponente zu verstehen: Auf dem STM32 werden BOOT, NORMAL und DEGRADED durch Bootdiagnose und Supervisor abgebildet; auf dem Raspberry Pi setzen die systemd-Zustände, Restart-Policies und Service-Watchdogs die Übergänge für einzelne Prozesse um. Die Zustände RECOVERY und ESKALATION fassen die jeweils ausgeführten Maßnahmen über beide Plattformen hinweg zusammen.

#vorlage("abb-3-4.png", "Systemweiter Zustandsautomat für Fehlerbehandlung und Recovery")

Im Zustand NORMAL sind die kritischen Subsysteme gesund und die reguläre Nutzfunktion ist verfügbar. Ein bestätigter Ausfall einer nicht kritischen oder externen Komponente führt zu DEGRADED; dort bleiben noch funktionsfähige Pfade aktiv und der Fehler wird nach außen sichtbar gemacht. RECOVERY ist ein transienter Zustand. Je nach Fehlerdomäne umfasst er das Verwerfen eines fehlerhaften Rahmens, einen begrenzten Retry, das erneute Öffnen eines Geräts, die I2C-Busfreigabe mit anschließender LCD-Initialisierung oder die Verifikation nach einem Dienstneustart. Der Übergang zurück zu NORMAL ist nur nach einem positiven Funktionsnachweis zulässig. Bleibt eine nicht kritische Störung bestehen, führt der Automat zurück nach DEGRADED.

ESKALATION wird erreicht, wenn ein kritisches Fortschrittskriterium verletzt wird oder die lokale Recovery innerhalb ihrer festgelegten Grenze erfolglos bleibt. Ein einzelner Linux-Dienst wird zunächst isoliert neu gestartet und anschließend im Zustand RECOVERY funktional geprüft. Kann die betroffene Ausführungsbasis selbst keine Recovery mehr durchführen, lösen IWDG beziehungsweise Raspberry-Pi-Hardware-Watchdog einen Reset aus; der nächste ausführbare Zustand ist dann BOOT. Damit bildet der Automat das Prinzip der feingranularen Recovery mit kontrollierter Eskalation ab \[#quelle(<lit-02>), S. 5 und 8; #quelle(<lit-06>), S. 31–32; #quelle(<lit-11>), S. 16\].

#echtetabelle("Übergänge des systemweiten Recovery-Zustandsautomaten", key: <tab-3-5>, (0.4fr, 1.5fr, 4fr), ([ID], [Übergang], [Auslöser beziehungsweise Bedingung],), (
  [T1],
  [BOOT → NORMAL],
  [Bootdiagnose abgeschlossen; alle für den Normalbetrieb benötigten Prüfungen erfolgreich.],
  [T2],
  [BOOT → DEGRADED],
  [Nicht kritische Komponente oder externe Ressource beim Start nicht verfügbar; Nutzfunktion bleibt möglich.],
  [T3],
  [BOOT → ESKALATION],
  [Kritische Initialisierung scheitert oder ein erforderlicher Fortschrittsnachweis bleibt aus.],
  [T4],
  [NORMAL → DEGRADED],
  [Bestätigter nicht kritischer Fehler, beispielsweise LCD-, GPS-, Netzwerk- oder RPI-Link-Ausfall.],
  [T5],
  [NORMAL → RECOVERY],
  [Fehler ist in der betroffenen Domäne lokal behandelbar.],
  [T6],
  [NORMAL → ESKALATION],
  [Kritisches Lebenszeichen oder der Fortschritt der Hauptfunktion fehlt.],
  [T7],
  [DEGRADED → RECOVERY],
  [Ressource ist wieder verfügbar oder der periodische Retry wird ausgeführt.],
  [T8],
  [RECOVERY → NORMAL],
  [Recovery wurde funktional verifiziert; alle benötigten Pfade sind wieder gesund.],
  [T9],
  [RECOVERY → DEGRADED],
  [Teilfunktion bleibt gestört, der Fehler ist jedoch weiterhin nicht kritisch.],
  [T10],
  [RECOVERY → ESKALATION],
  [Retry-Grenze erreicht, Recovery fehlgeschlagen oder kritischer Fehler besteht fort.],
  [T11],
  [ESKALATION → RECOVERY],
  [Isolierter Dienstneustart ist abgeschlossen; die Nutzfunktion wird anschließend geprüft.],
  [T12],
  [ESKALATION → BOOT],
  [IWDG-Reset des STM32 oder Hardware-Reboot des Raspberry Pi wurde ausgelöst.],
))

// Vorlage: PDF-Seite 27
== Erfolgskriterien des Gesamtkonzepts <sec-3-9>

Das Systemkonzept gilt als erfolgreich umgesetzt, wenn die folgenden Punkte experimentell nachgewiesen werden:

- Fehler werden der vorgesehenen Fehlerklasse zugeordnet.

- Die Recovery bleibt auf die kleinste ausreichende Ebene beschränkt.

- Funktionsfähige Dienste bleiben bei Fehlern anderer Dienste aktiv.

- Hängende Software wird auch dann erkannt, wenn der Prozess formal noch existiert.

- Nach Wegfall der Störung wird der funktionale Endzustand ohne manuellen Neustart erreicht.

- Reset- und Neustartursachen sind über Logs oder Diagnoseausgaben nachvollziehbar.
