#import "../layout.typ": *

// Fortsetzung des kombinierten Kapitels 3.
== Raspberry-Pi-Teilsystem <sec-4-2>

Der Raspberry Pi realisiert die ersten drei Stufen aus #ref(<tab-3-4>, supplement: [Tabelle]). Ausgangspunkt sind die NMEA-Daten des GPS-Empfängers. Aus dem daraus erzeugten Positionszustand wird die Anfrage an den Wetterdienst abgeleitet; dessen Antwort ergänzt die positionsbezogenen Wetterdaten. Ausgang des Teilsystems ist ein aus beiden Zuständen gebildeter UART-Rahmen.

weather-gps.service schreibt den Positionszustand nach /dev/shm/weather/gps.json. weather-net.service liest diesen Zustand und erzeugt daraus weather.json. weather-uart.service liest beide Dateien, bildet den seriellen Rahmen und besitzt exklusiv /dev/serial0. Die Zustandsdateien sind damit zugleich Übergabepunkte des Nutzdatenpfads und Beobachtungspunkte für Aktualität und Fehlerzustand. #ref(<abb-3-2>, supplement: [Abbildung]) zeigt den gerichteten Datenfluss und die Grenzen der drei Prozesse.

#vorlage("abb-3-2.png", "Detailansicht des Raspberry-Pi-Teilsystems mit entkoppelten Diensten und Zustandsdateien")

=== Gemeinsame Konfiguration und Zustandsaustausch <sec-4-2-1>

Zentrale Konstanten definieren Schnittstellen, Timeouts und Zyklen. Der GPS- und Wetterabrufdienst laufen mit einer Periode von 10 s, der UART-Dienst mit 5 s. Ein Zustandsdokument wird nach 30 s ohne Aktualisierung als veraltet behandelt. Die letzte Position darf höchstens zwei Stunden alt sein, bevor sie nicht mehr als Fallback verwendet wird. Der folgende Auszug zeigt die dafür maßgeblichen Konfigurationswerte:

```python
GPS_PORT = "/dev/ttyACM0"
UART_PORT = "/dev/serial0"
BAUDRATE_GPS = 9600
BAUDRATE_UART = 115200

GPS_POLL_INTERVAL_SECONDS = 10
NET_POLL_INTERVAL_SECONDS = 10
UART_POLL_INTERVAL_SECONDS = 5
STATE_MAX_AGE_SECONDS = 30
MAX_POSITION_AGE_SECONDS = 2 * 60 * 60

USE_UART_CHECKSUM = True
STM32_RESPONSE_TIMEOUT_SECONDS = 2.0
STM32_SEND_RETRIES = 1
```

Die Dienste tauschen kleine JSON-Dokumente in /dev/shm/weather aus. Das Verzeichnis liegt auf tmpfs, wodurch periodische Schreibzugriffe auf die SD-Karte vermieden werden. Ein Zustand enthält neben Nutzdaten einen Zeitstempel. Die Schreibfunktion erzeugt zuerst eine temporäre Datei und ersetzt anschließend den Zielpfad atomar. Dadurch liest ein anderer Dienst entweder den alten oder den vollständig neuen Zustand, nicht jedoch ein teilweise geschriebenes JSON-Dokument.

Diese Entkopplung begrenzt zugleich die Recovery-Domäne: Ein betroffener Dienst kann neu gestartet werden, ohne die beiden anderen Prozesse ebenfalls zurückzusetzen. Der flüchtige Speicher verhindert außerdem veraltete Boot-Zustände, weil nach einem Neustart keine alten Dateien existieren, die fälschlich als aktuelle Messwerte interpretiert werden könnten.

=== GPS-Erfassung <sec-4-2-3>

Der GPS-Dienst bildet den Eingang des Nutzdatenpfads. Er öffnet /dev/ttyACM0, liest RMC-Sätze und akzeptiert nur Datensätze mit gültigem Status. Breiten- und Längengrad werden aus Grad und Minuten in Dezimalgrad umgerechnet. Ein gültiger Fix aktualisiert fix_ts, den Zeitstempel der letzten gültigen Position; ein fehlendes Gerät, ein Timeout oder ein ungültiger Status führt zu have_fix=false.

Der Zeitstempel ermöglicht den nachgelagerten Diensten, einen aktuellen Fix von einer noch zulässigen letzten Position zu unterscheiden. Der Prozess bleibt bei einem Eingabefehler aktiv und öffnet das Gerät im nächsten Zyklus erneut. Die lokale Recovery besteht somit zunächst im erneuten Gerätezugriff; erst ein Prozessfehler führt zum isolierten Dienstneustart.

=== Wetterabruf und Abgrenzung der Fehlerursachen <sec-4-2-4>

Der Wetterabrufdienst mit dem technischen Namen weather-net.service liest eine aktuelle oder noch zulässige letzte Position und ruft die Open-Meteo-Schnittstelle über HTTPS ab \[#quelle(<lit-17>), Abschn. "Weather Forecast API"\]. Sein Ausgang ist der Wetterzustand in weather.json, der zusammen mit der verwendeten Position die Eingabe des UART-Dienstes bildet.

Fachlich sind mindestens zwei Fehlerdomänen zu unterscheiden. Ein Fehler des Netzwerkpfads liegt vor, wenn die lokale Schnittstelle, Adressierung oder Route nicht verfügbar ist oder Namensauflösung, TCP-Verbindung beziehungsweise TLS-Aufbau scheitern. Nach einem begrenzten Retry ist hier zunächst die lokale Konnektivität zu diagnostizieren; nur bei einem bestätigten lokalen Fehler wäre eine Reinitialisierung der Netzwerkschnittstelle oder ihrer Konfiguration angemessen. GPS-Erfassung und UART-Übertragung bleiben davon unabhängig aktiv.

Ein Fehler des Wetterdienstes liegt dagegen vor, wenn der Netzwerkpfad grundsätzlich funktioniert, der Anbieter aber beispielsweise mit einem Dienstfehler oder einer Ratenbegrenzung antwortet. Auch eine syntaktisch oder semantisch nicht auswertbare Antwort bildet eine eigene Datenfehlerklasse. In diesen Fällen würde ein Zurücksetzen der Netzwerkschnittstelle die Ursache nicht beseitigen. Angemessen sind das Kennzeichnen nicht verfügbarer Wetterdaten, ein dienstspezifischer Retry mit Backoff und das Verwerfen ungültiger Antworten; ein Plattform-Reset ist wegen einer fortbestehenden externen Störung nicht vorgesehen.

#block(breakable: false)[Ein ursachenspezifisches Zustandsmodell benötigt deshalb zwei getrennte Größen: #box[NET_PATH] mit den Werten OK, ERR und UNKNOWN für die Konnektivität sowie #box[WEATHER] mit OK, SERVICE_ERR, DATA_ERR und UNKNOWN für Dienst und Antwort. Bei #box[NET_PATH=ERR] ist der Wetterdienst nicht beobachtbar; #box[WEATHER] muss daher #box[UNKNOWN] sein. SERVICE_ERR oder DATA_ERR sind nur bei nachgewiesenem #box[NET_PATH=OK] zulässig. Daraus folgen getrennte Reaktionen: Netzwerkdiagnose und gegebenenfalls Wiederverbindung bei #box[NET_PATH=ERR], aber API-spezifischer Retry beziehungsweise Antwortverwerfung ohne Netzwerkreset bei einem #box[WEATHER]-Fehler.]

Der implementierte Prototyp besitzt diese gestufte Diagnose noch nicht. Er fasst Verbindungs-, Dienst- und Antwortfehler in weather.json als ok=false mit reason=net_error zusammen und behandelt sie mit demselben periodischen Retry. Derselbe Sammelfehler erscheint im Journal als INTERNET_ERROR und im UART-Protokoll als NET=ERR. Diese Bezeichnungen kennzeichnen somit ausschließlich einen nicht verfügbaren gültigen Wetterzustand und erlauben keine Aussage darüber, ob das Netzwerk selbst oder der Wetterdienst die Ursache ist. Die Weitergabe als degradierter Zustand verhindert dennoch, dass GPS-Erfassung oder UART-Prozess unnötig zurückgesetzt werden.

=== Prozessüberwachung und Plattform-Recovery <sec-4-3>

Die Recovery des Raspberry Pi besitzt zwei Ebenen. Auf der Dienstebene überwacht systemd jeden der drei Prozesse separat. Auf der Plattformebene erkennt der Hardware-Watchdog einen Stillstand der gemeinsamen Linux-Ausführungsbasis. Damit folgt die Implementierung derselben Grenze wie der Nutzdatenpfad: Zunächst wird nur die fehlerhafte Komponente behandelt; erst wenn diese lokale Instanz nicht mehr handlungsfähig ist, wird die gesamte Plattform neu gestartet.

*Dienstebene.* Alle drei Dienste verwenden denselben Neustart- und Watchdog-Ansatz. Ein gemeinsames weather.target startet und stoppt die Prozesse als Gruppe, ohne ihre individuelle Steuerbarkeit aufzuheben. Der folgende Auszug zeigt die wesentlichen Einstellungen eines Dienstes:

```ini
[Service]
Type=notify
NotifyAccess=main
User=pi
WorkingDirectory=/home/pi/weather
ExecStart=/usr/bin/python3 -m rpi.service_gps
Restart=always
RestartSec=5
WatchdogSec=30s
```

Restart=always veranlasst nach jeder Prozessbeendigung einen Neustart; RestartSec=5 legt davor eine Wartezeit von fünf Sekunden fest. WatchdogSec=30s definiert die Frist für Fortschrittsmeldungen. systemd stellt diesen Wert der Anwendung über WATCHDOG_USEC in Mikrosekunden bereit. Type=notify verlangt zusätzlich, dass der Dienst seine abgeschlossene Initialisierung ausdrücklich meldet. Die Anwendung sendet das Lebenszeichen typischerweise nach der halben erlaubten Zeit und aktualisiert es auch während kontrollierter Wartezeiten, damit ein langer I/O-Timeout nicht fälschlich als Prozess-Hänger gilt. Die Semantik entspricht der offiziellen systemd-API \[#quelle(<lit-07>), Abschn. WatchdogSec=, #quelle(<lit-08>), Abschn. WATCHDOG=1\].

*Plattformebene.* systemd aktualisiert zusätzlich periodisch /dev/watchdog0. Die Einstellung RuntimeWatchdogSec= ist in der systemd-Systemkonfiguration dokumentiert \[#quelle(<lit-20>), Abschn. RuntimeWatchdogSec=\]; die Kommunikation mit dem Gerät folgt der Linux-Watchdog-API \[#quelle(<lit-03>), Abschn. "The simplest API"\]. Der Versuch verwendet den BCM2835-Watchdog. Angefordert wurde RuntimeWatchdogSec=10s, der aktive Treiber meldete jedoch einen wirksamen Hardware-Timeout von 60 s. Das Werkzeug wdctl liest Konfiguration und Status des Geräts aus; der protokollierte Auszug ist in Quelltext C.6 wiedergegeben. Der Kernel-Panic-Test prüft die vollständige Kette aus ausbleibendem Keepalive, Hardware-Reset, Linux-Boot und automatischem Dienststart.

== UART als Plattformgrenze <sec-3-6>

Die UART-Verbindung ist die einzige Schnittstelle zwischen den beiden internen Plattformen Raspberry Pi und STM32. Sie transportiert Nutzdatenrahmen zum STM32 sowie Bestätigungen, Fehlermeldungen und Heartbeat-Nachrichten in beiden Richtungen. Entwurf und Implementierung werden deshalb gemeinsam aus Sicht des Nachrichtenflusses, des Senders und des Empfängers beschrieben.

=== Nachrichten, Integrität und Betriebsmodi <sec-3-6-1>

Vor jedem Nutzdatenrahmen sendet der Raspberry Pi PING; der STM32 antwortet mit PONG. Dadurch wird nicht nur geprüft, ob die UART-Schnittstelle offen ist, sondern ob die Firmware eine Nachricht empfangen, verarbeiten und eine Antwort erzeugen kann.

Ein Wetterdatenrahmen besitzt grundsätzlich folgende Form:

```text
GPS=OK;NET=OK;TEMP=19.3;WIND=10.2;CODE=3;MODE=LIVE*XX
```

Die Nutzdaten werden durch Schlüssel-Wert-Paare beschrieben. GPS kennzeichnet die Verfügbarkeit eines aktuellen Positionsfix. Das historisch benannte Feld NET ist im implementierten Protokoll dagegen ein zusammengefasster Gültigkeitsstatus des Wetterdatenpfads: NET=ERR bedeutet, dass kein gültiger aktueller Wetterzustand vorliegt, nicht dass eine Störung der physischen oder allgemeinen Netzwerkkonnektivität nachgewiesen wurde. TEMP enthält die Lufttemperatur in Grad Celsius, WIND die Windgeschwindigkeit in Kilometern pro Stunde und CODE den von Open-Meteo gelieferten numerischen Wettercode nach der WMO-Systematik \[#quelle(<lit-17>), Abschn. "Weather Forecast API"\]. MODE unterscheidet aktuelle Positionsdaten (LIVE) von der gekennzeichneten Verwendung einer letzten noch zulässigen Position (LAST); zwei Bindestriche stehen für einen nicht verfügbaren Wert.

Nach dem Sternzeichen folgt mit XX eine zweistellig hexadezimal dargestellte XOR-Prüfsumme über alle vorherigen ASCII-Bytes. Der STM32 akzeptiert einen Rahmen erst nach erfolgreicher Prüfung und bestätigt ihn mit OK; diese Antwort wird im Folgenden auch als Daten-ACK bezeichnet. Ein ungültiger Rahmen wird mit ERR:CHECKSUM abgelehnt. Bei Überschreitung des Empfangspuffers wird ERR:BUFFER zurückgegeben.

MODE=LIVE kennzeichnet aktuelle Daten auf Grundlage eines gültigen GPS-Fix. Bei Verlust des GPS-Empfangs bleiben zuletzt bekannte Daten verfügbar und werden mit MODE=LAST sowie GPS=ERR gekennzeichnet. Dadurch bleibt der Systemzustand transparent; veraltete Daten werden nicht als aktuelle Daten dargestellt. Das Protokoll stellt damit sowohl Nutzdaten als auch die Signale für Übertragungs- und Verarbeitungsfehler bereit.

=== Sendeimplementierung auf dem Raspberry Pi <sec-4-2-5>

Nur weather-uart.service öffnet /dev/serial0. Nach erfolgreichem PING/PONG-Zyklus kombiniert der Dienst die Zustände der beiden anderen Prozesse. Bei einem gültigen aktuellen Fix überträgt er GPS=OK;MODE=LIVE. Fehlt ein aktueller Fix, ist gps.json aber jünger als 30 s und die letzte gültige Position höchstens zwei Stunden alt, wird GPS=ERR;MODE=LAST übertragen. Ohne eine solche zulässige Fallback-Position werden GPS=ERR und die übrigen Nutzfelder mit zwei Bindestrichen als nicht verfügbar gekennzeichnet. Ein aus beliebiger Ursache fehlgeschlagener Wetterabruf wird im derzeitigen Protokoll als NET=ERR dargestellt. Die XOR-Prüfsumme wird über die ASCII-Bytes vor dem Stern berechnet:

```python
def checksum_xor(text: str) -> int:
    value = 0
    for byte in text.encode("ascii"):
        value ^= byte
    return value

frame = f"{payload}*{checksum_xor(payload):02X}\n"
```

Der Dienst durchsucht mehrere Antwortzeilen, weil der STM32 vor dem finalen PONG oder OK zusätzliche Diagnosemeldungen ausgeben kann. STM32_CONNECTION_ERROR bezeichnet im Raspberry-Pi-Journal einen fehlgeschlagenen PING/PONG-Zyklus; RPI_LINK_RECOVERED meldet auf STM32-Seite die anschließend wiederhergestellte Verbindung. Bleibt die finale Bestätigung aus, wird der Rahmen einmal wiederholt; anschließend wird der Fehler protokolliert, ohne den Prozess zu beenden.

=== Empfang, Validierung und Resynchronisation auf dem STM32 <sec-4-5-4>

Die UART-Routine arbeitet nicht blockierend und besitzt eine feste Rahmenlänge. Bei Überschreitung wird der laufende Rahmen verworfen und ERR:BUFFER gesendet. Ein vollständiger Wetterrahmen wird erst nach Prüfung des Stern-Trennzeichens und der XOR-Prüfsumme geparst. Ein Fehler führt zu ERR:CHECKSUM; ein gültiger Rahmen zu OK.

Die Tests U1 und U2 prüfen zusätzlich, ob nach dem Fehler sofort wieder ein PING und ein gültiger Wetterrahmen verarbeitet werden können. Damit wird nicht nur die Erkennung, sondern auch die Wiederherstellung der Parser-Synchronisation bewertet. Nach erfolgreicher Validierung werden die Nutzdaten an den LCD-Treiber weitergegeben; die Antwort schließt zugleich den Rückmeldepfad zum Raspberry Pi.

== STM32-Teilsystem <sec-4-5>

Der STM32 bildet die Ausgabe- und hardwarenahe Überwachungsebene. Sein Eingang sind die an der UART-Grenze validierten Daten und Heartbeat-Nachrichten. Seine sichtbare Nutzfunktion ist die LCD-Darstellung; parallel überwachen Bootdiagnose, Supervisor und IWDG den Fortschritt der Firmware sowie den Zustand der Peripherie.

=== Firmwarestruktur, Bootablauf und Diagnose <sec-4-5-1>

Die Firmware ist CMSIS-basiert und in Treiber-, Diagnose- und Anwendungsmodule zerlegt. Zu den Modulen gehören Systemzeit, UART, I2C, LCD2004, Nachrichtenparser, Supervisor, Power-Monitor, Bootdiagnose und IWDG. CMSIS stellt die standardisierten Cortex-M-Kern- und Registerdefinitionen bereit \[#quelle(<lit-21>), Abschn. "CMSIS-Core"\]; die Peripherieregister werden direkt konfiguriert.

Nach dem Reset werden Takt, SysTick, UART, I2C, Power-Monitor und Supervisor initialisiert. SysTick stellt dabei die periodische Zeitbasis der Firmware bereit. Die Bootdiagnose prüft I2C/LCD, UART-Kommunikation und den Watchdog. Zusätzlich werden die RCC-Resetflags gelesen und anschließend gelöscht; diese Statusbits des Reset-and-Clock-Control-Blocks dokumentieren die vorherige Reset-Ursache. Die Diagnose unterscheidet unter anderem Pin-, Software- und IWDG-Reset. Erst nach Abschluss wechselt der Supervisor vom Boot- in den Laufzeitmodus. Diesen Eintritt meldet die Firmware mit APP_RUNTIME; beim Test H1 dient die Diagnosemeldung als funktionaler Endzeitpunkt.

#vorlage("abb-4-1.png", "Vereinfachter Boot- und Recovery-Ablauf des STM32")

=== LCD-Ausgabe und lokale I2C-Recovery <sec-4-5-5>

Nach einem gültigen UART-Rahmen aktualisiert der LCD-Treiber die Wetter- und Statusanzeige. Die LCD-Gesundheit wird jede Sekunde geprüft. Einzelne Fehlschläge ändern den Zustand noch nicht; erst drei aufeinander folgende Fehler bestätigen den Ausfall.

Der Treiber begrenzt I2C-Wartezeiten durch Software-Timeouts, damit ein dauerhaft gesetztes BUSY-Flag die Hauptschleife nicht unbegrenzt blockiert. Anschließend kann er die Peripherie zurücksetzen und bis zu neun SCL-Pulse zur Busfreigabe erzeugen. Bei bestätigtem Ausfall wird LCD_DRIVER=FAIL und der globale Modus DEGRADED gesetzt. Hauptschleife und UART-Verbindung bleiben dabei aktiv.

Nach drei erfolgreichen Proben wird das LCD neu initialisiert, der Recovery-Zähler erhöht und der Modus wieder zu NORMAL geändert. Die Konfiguration RESET_AFTER_LCD_STABLE_RECOVERY=0 stellt sicher, dass die Wiederkehr des nicht kritischen Displays keinen vollständigen Mikrocontroller-Reset auslöst. Damit bleiben Erkennung und Recovery auf die betroffene Peripherie begrenzt.

=== Supervisor, Gesundheitsmodell und IWDG <sec-4-5-2>

Bootdiagnose, Hauptschleife, UART-Verarbeitung und LCD-Treiber melden ihren Zustand an den Supervisor. Die internen Bezeichner ordnen die überwachten Funktionen eindeutig zu: BOOT bezeichnet die Startdiagnose, MAIN_LOOP den Fortschritt der Hauptschleife, UART_DRIVER und LCD_DRIVER die beiden Peripherietreiber, RPI_LINK die Heartbeat-Verbindung zum Raspberry Pi und POWER_SUPPLY die Spannungsüberwachung. BOOT wird daneben auch als globaler Systemzustand während des Starts verwendet; aus dem Kontext ist jeweils ersichtlich, ob der Supervisor-Eintrag oder der globale Modus gemeint ist.

Jeder Eintrag enthält Aktivierung, Kritikalität, Gesundheitszustand und Zeitpunkt des letzten Fortschritts. Für kritische Subsysteme gelten Laufzeitgrenzen von typischerweise 3 s; RPI_LINK und LCD_DRIVER sind nicht kritisch für den IWDG-Refresh. Bei einem bestätigten nicht kritischen Fehler wechselt das System zu DEGRADED. Ein Stillstand der Hauptschleife verhindert dagegen die Freigabe des IWDG-Lebenszeichens. Diagnosebefehle liefern Alter, Zustand und Kritikalität der Subsysteme sowie kumulative Fehler- und Recovery-Zähler.

Der IWDG wird mit dem LSI-Oszillator betrieben. Im Normalbetrieb erfolgt ein Refresh nur, wenn supervisor_all_critical_ok() wahr ist. Damit ist die Watchdog-Aktualisierung an den Fortschritt der kritischen Funktionspfade und nicht nur an einen periodischen Interrupt gekoppelt. Der Diagnosebefehl HANG bestätigt zunächst mit HANGING, setzt eine verkürzte IWDG-Periode und verbleibt anschließend absichtlich in einer Endlosschleife. Nach dem Reset weist die Bootdiagnose den IWDG als Ursache aus. Dieser Testpfad ist ausschließlich für die Evaluation vorgesehen.

=== Spannungsüberwachung <sec-4-5-6>

Der STM32-PVD und ein Supervisor-Eintrag POWER_SUPPLY sind in der Firmware vorbereitet. Die Zustandsänderung wird entprellt und kann als kritisch bewertet werden. Ergänzend wurde das Verhalten der vollständigen Nucleo-Platine bei schrittweise abgesenkter VIN-Spannung untersucht. Die Implementierung bildet damit einen eigenen Beobachtungspfad; eine Sicherung des Ausführungszustands in nichtflüchtigem Speicher ist nicht Bestandteil des Systems.

== Systemweites Recovery-Zusammenspiel <sec-3-7>

Im Normalbetrieb entsteht aus den empfangenen NMEA-Daten zunächst der Positionszustand in gps.json. Der Wetterabrufdienst ergänzt ihn zum Wetterzustand in weather.json, aus dem der UART-Dienst den seriellen Rahmen bildet. Der STM32 validiert diesen Rahmen, meldet das Verarbeitungsergebnis zurück und aktualisiert bei gültigen Daten das LCD. Zustandsdateien und UART-Verbindung sind damit sowohl Übergabe- als auch Beobachtungspunkte des Gesamtsystems.

Bei einem Fehler greift zunächst die Recovery-Ebene, die der betroffenen Grenze am nächsten liegt. Ungültige Rahmen werden verworfen, externe GPS- oder Wetterfehler als degradierter Zustand weitergegeben und fehlerhafte Linux-Dienste durch systemd isoliert neu gestartet. Auf dem STM32 werden Peripheriefehler lokal behandelt; nur ein kritischer Firmware-Stillstand führt über den IWDG zum Reset. Erst wenn die jeweilige Plattform ihre Recovery nicht mehr selbst ausführen kann, wird auf die systemweite Reset-Ebene eskaliert.

=== Eskalationshierarchie

Das Recovery-Konzept ordnet die Maßnahmen nach zunehmender Eingriffstiefe:

Ebene 1: Datenrahmen verwerfen: ungültige Prüfsumme oder zu langer Rahmen.

Ebene 2: Lokale Komponente reinitialisieren: LCD-/I2C-Fehler.

Ebene 3: Degradierter Betrieb und Retry: GPS-Fehler oder nicht verfügbarer Wetterdatenpfad.

Ebene 4: Einzelnen Dienst neu starten: Prozessabsturz oder Service-Watchdog-Timeout.

Ebene 5: Mikrocontroller zurücksetzen: Firmware-Hänger des STM32.

Ebene 6: Raspberry Pi neu starten: Kernel-Hänger oder vollständiger Systemfehler.

#vorlage("abb-3-3.png", "Eskalationshierarchie der Recovery-Strategien")

Die Ebenen konkretisieren die in #ref(<tab-3-4>, supplement: [Tabelle]) ausgewiesenen Recovery-Grenzen: Die Ebenen 1 und 2 behandeln Daten- und Peripheriefehler unmittelbar auf dem STM32. Die Ebenen 3 und 4 betreffen externe Ressourcen beziehungsweise einzelne Raspberry-Pi-Dienste. Die Ebenen 5 und 6 setzen schließlich die jeweilige Ausführungsbasis zurück. Diese Reihenfolge minimiert die Eingriffstiefe und erhält funktionsfähige Zustände so lange wie möglich.

=== Verteilter Recovery-Zustandsautomat <sec-3-8>

Der globale Systemzustand unterscheidet zwischen stabilen Betriebszuständen und transienten Recovery-Zuständen. Der in #ref(<abb-3-4>, supplement: [Abbildung]) dargestellte Automat ist eine systemweite Abstraktion der verteilten Implementierung. Er ist nicht als zusätzliche monolithische Softwarekomponente zu verstehen: Auf dem STM32 werden BOOT, NORMAL und DEGRADED durch Bootdiagnose und Supervisor abgebildet; auf dem Raspberry Pi setzen die systemd-Zustände, Restart-Policies und Service-Watchdogs die Übergänge für einzelne Prozesse um. Die Zustände RECOVERY und ESKALATION fassen die jeweils ausgeführten Maßnahmen über beide Plattformen hinweg zusammen.

#vorlage("abb-3-4.png", "Systemweiter Zustandsautomat für Fehlerbehandlung und Recovery")

Im Zustand NORMAL sind die kritischen Subsysteme gesund und die reguläre Nutzfunktion ist verfügbar. Ein bestätigter Ausfall einer nicht kritischen oder externen Komponente führt zu DEGRADED; dort bleiben noch funktionsfähige Pfade aktiv und der Fehler wird nach außen sichtbar gemacht. RECOVERY ist ein transienter Zustand. Je nach Fehlerdomäne umfasst er das Verwerfen eines fehlerhaften Rahmens, einen begrenzten Retry, das erneute Öffnen eines Geräts, die I2C-Busfreigabe mit anschließender LCD-Initialisierung oder die Verifikation nach einem Dienstneustart. Der Übergang zurück zu NORMAL ist nur nach einem positiven Funktionsnachweis zulässig. Bleibt eine nicht kritische Störung bestehen, führt der Automat zurück nach DEGRADED.

ESKALATION wird erreicht, wenn ein kritisches Fortschrittskriterium verletzt wird oder die lokale Recovery innerhalb ihrer festgelegten Grenze erfolglos bleibt. Ein einzelner Linux-Dienst wird zunächst isoliert neu gestartet und anschließend im Zustand RECOVERY funktional geprüft. Kann die betroffene Ausführungsbasis selbst keine Recovery mehr durchführen, lösen IWDG beziehungsweise Raspberry-Pi-Hardware-Watchdog einen Reset aus; der nächste ausführbare Zustand ist dann BOOT. Damit bildet der Automat das Prinzip der feingranularen Recovery mit kontrollierter Eskalation ab \[#quelle(<lit-02>), S. 5 und 8; #quelle(<lit-06>), S. 31–32; #quelle(<lit-11>), S. 16\].

#echtetabelle("Übergänge des systemweiten Recovery-Zustandsautomaten", key: <tab-3-5>, (0.4fr, 2fr, 3.5fr), ([ID], [Übergang], [Auslöser beziehungsweise Bedingung],), (
  [T1],
  [BOOT → NORMAL],
  [Bootdiagnose erfolgreich; alle benötigten Funktionen verfügbar.],
  [T2],
  [BOOT → DEGRADED],
  [Nicht kritische Ressource fehlt; Nutzfunktion bleibt möglich.],
  [T3],
  [BOOT → ESKALATION],
  [Kritische Initialisierung oder Fortschrittsnachweis fehlgeschlagen.],
  [T4],
  [NORMAL → DEGRADED],
  [Bestätigter nicht kritischer LCD-, GPS-, Netzwerkpfad-, Wetterdienst- oder RPI-Link-Fehler.],
  [T5],
  [NORMAL → RECOVERY],
  [Fehler ist in der betroffenen Domäne lokal behandelbar.],
  [T6],
  [NORMAL → ESKALATION],
  [Kritisches Lebenszeichen oder Fortschritt der Hauptfunktion fehlt.],
  [T7],
  [DEGRADED → RECOVERY],
  [Ressource wieder verfügbar oder periodischer Retry fällig.],
  [T8],
  [RECOVERY → NORMAL],
  [Recovery verifiziert; alle benötigten Pfade wieder gesund.],
  [T9],
  [RECOVERY → DEGRADED],
  [Teilfunktion bleibt nicht kritisch gestört.],
  [T10],
  [RECOVERY → ESKALATION],
  [Interne lokale Recovery fehlgeschlagen oder kritischer Fehler fortbestehend; ein rein externer Fehler bleibt DEGRADED.],
  [T11],
  [ESKALATION → RECOVERY],
  [Dienstneustart abgeschlossen; Nutzfunktion wird geprüft.],
  [T12],
  [ESKALATION → BOOT],
  [IWDG-Reset des STM32 oder Hardware-Reboot des Raspberry Pi ausgelöst.],
))

=== Diagnose und Nachvollziehbarkeit <sec-4-6>

Die Linux-Dienste protokollieren Ereignisse im systemd-Journal und Status in JSON-Dateien; der STM32 liefert Diagnosen über UART. Vor jeder Fehlerinjektion sichern die Testskripte einen Journal-Cursor, Konsolenausgabe, Rohlogs, CSV-Einzelwerte und statistische Zusammenfassungen. Das vollständige Evaluationsverzeichnis wurde archiviert und mit SHA-256 versehen. Damit werden die betrieblichen Beobachtungspunkte zu reproduzierbaren Messbelegen.

== Erfolgskriterien <sec-3-9>

Das integrierte Systemkonzept gilt als erfolgreich umgesetzt, wenn Fehler der vorgesehenen Klasse zugeordnet werden, ohne funktionsfähige Domänen zu beeinträchtigen; wenn die Recovery auf der kleinsten ausreichenden Ebene bleibt und auch hängende Prozesse erkennt; und wenn nach Wegfall der Störung der funktionale Endzustand ohne manuellen Neustart erreicht wird sowie Reset- und Neustartursachen nachvollziehbar bleiben.
