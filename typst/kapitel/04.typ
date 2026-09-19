#import "../layout.typ": *

// Vorlage: PDF-Seite 29
= Implementierung <sec-4>

Kapitel 3 hat die logische Architektur und die Recovery-Grenzen festgelegt. Dieses Kapitel folgt demselben Datenpfad und beschreibt die konkrete Umsetzung der Schnittstellen, Dienste und Überwachungsmechanismen.

// Vorlage: PDF-Seite 29
== Hardwareaufbau <sec-4-1>

// VORLAGE PDF S. 29: Der rechte Seitenrand schneidet STM32 auf ST ab.
Der Hardwareaufbau setzt den in Abbildung 3.1 beschriebenen Datenpfad physisch um: Der GPS-Empfänger ist per USB mit dem Raspberry Pi verbunden, Raspberry Pi und STM32 kommunizieren über UART und der ST steuert das LCD über I2C. Tabelle 4.1 fasst die dafür relevanten Schnittstellen und Parameter zusammen.

#echtetabelle("Tabelle 4.1: Wesentliche Schnittstellen und Konfigurationswerte", (1.3fr, 1.4fr, 2.4fr), ([Funktion], [Anschluss], [Konfiguration],), (
  [GPS am Raspberry Pi],
  [/dev/ttyACM0],
  [USB-CDC, 9.600 Bd, NMEA],
  [UART am Raspberry Pi],
  [/dev/serial0],
  [115.200 Bd, 8N1],
  [USART1 am STM32],
  [PA9 (TX), PA10 (RX)],
  [Alternate Function 7, 115.200 Bd],
  [I2C1 am STM32],
  [PB6 (SCL), PB7 (SDA)],
  [Alternate Function 4, Open Drain, 100 kHz],
  [LCD2004 mit I2C-Adapter],
  [Adresse 0x27],
  [20 Zeichen × 4 Zeilen, HD44780-kompatibler 4-Bit-Modus],
  [Systemtakt STM32],
  [HSI16],
  [16 MHz],
))

Im Versuchsaufbau wurde für den LCD-Adapter ausschließlich die 7-Bit-I2C-Adresse 0x27 verwendet. Die Registerkonfiguration orientiert sich am STM32-Referenzhandbuch \[4, S. 1151-1183, Abschn. 38.1-38.4.10\]. I2C-Zugriffe besitzen Software-Timeouts, damit ein dauerhaft gesetztes BUSY-Flag die Hauptschleife nicht unbegrenzt blockiert.

// Vorlage: PDF-Seite 29
== Raspberry-Pi-Softwarearchitektur <sec-4-2>

Die Python-Anwendung ist in drei Prozesse aufgeteilt. Jeder Dienst besitzt eine klar abgegrenzte Verantwortung und eine eigene systemd-Überwachung. Diese Partitionierung reduziert den Umfang einer Recovery: Ein Fehler der Wetterabfrage erfordert keinen Neustart des GPS-Empfangs und keinen Verlust der UART-Verbindung.

// Vorlage: PDF-Seite 29
=== Gemeinsame Konfiguration <sec-4-2-1>

Zentrale Konstanten definieren Schnittstellen, Zeitouts und Zyklen. Der GPS- und Netzwerkdienst laufen mit einer Periode von 10 s, der UART-Dienst mit 5 s. Ein Zustandsdokument wird nach 30 s ohne Aktualisierung als veraltet behandelt. Die letzte Position darf höchstens zwei Stunden alt sein, bevor sie nicht mehr als Fallback verwendet wird. Quelltext 4.1: Auszug der Raspberry-Pi-Konfiguration

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

// Vorlage: PDF-Seite 30
=== Zustandsaustausch und atomare Aktualisierung <sec-4-2-2>

Die Dienste tauschen kleine JSON-Dokumente in /dev/shm/weather aus. Das Verzeichnis liegt auf tmpfs, wodurch periodische Schreibzugriffe auf die SD-Karte vermieden werden. Ein Zustand enthält neben Nutzdaten einen Zeitstempel. Die Schreibfunktion erzeugt zuerst eine temporäre Datei und ersetzt anschließend den Zielpfad atomar. Dadurch liest ein anderer Dienst entweder den alten oder den vollständig neuen Zustand, nicht jedoch ein teilweise geschriebenes JSON-Dokument.

Der flüchtige Speicher ist zugleich eine Sicherheitsmaßnahme gegen veraltete Boot- Zustände. Nach einem Neustart existieren keine alten Dateien, die fälschlich als aktuelle Messwerte interpretiert werden könnten.

// Vorlage: PDF-Seite 31
=== GPS-Dienst <sec-4-2-3>

Der GPS-Dienst öffnet /dev/ttyACM0, liest RMC-Sätze und akzeptiert nur Datensätze mit gültigem Status. Breiten- und Längengrad werden aus Grad und Minuten in Dezimalgrad umgerechnet. Ein gültiger Fix aktualisiert fix\_ts; ein fehlendes Gerät, ein Timeout oder ein ungültiger Status führt zu have\_fix=false. Der Prozess bleibt aktiv und öffnet das Gerät im nächsten Zyklus erneut. Dadurch ist kein manueller Neustart des Dienstes notwendig, wenn das USB-Gerät zurückkehrt.

// Vorlage: PDF-Seite 31
=== Netzwerkdienst <sec-4-2-4>

// VORLAGE PDF S. 31: Am rechten Rand steht ein isoliertes Restzeichen u.
Der Dienst liest eine aktuelle oder noch zulässige letzte Position und ruft die Open-Meteo- Schnittstelle über HTTPS ab \[17, Abschn. "Weather Forecast API"\]. Für die Fehleranalyse sind drei Ursachen zu unterscheiden: fehlende Netzwerkkonnektivität beziehungsweise DNS/TLS-Fehler, Nichterreichbarkeit oder Fehler des Wetterdienstes sowie eine nicht u auswertbare Antwort. Die aktuelle Implementierung fasst diese Ursachen in weather.json noch zu ok=false mit reason=net\_error zusammen und behandelt sie mit demselben periodischen Retry. Diese Vereinfachung wird bei der Interpretation berücksichtigt.

// Vorlage: PDF-Seite 31
=== UART-Dienst und Protokollbildung <sec-4-2-5>

// VORLAGE PDF S. 31: Zwischen Bei und Position verfügbar fehlt ein Satzteil.
Nur der UART-Dienst öffnet /dev/serial0. Vor jedem Nutzdatenrahmen sendet er PING und erwartet PONG. Anschließend kombiniert er die Zustände der anderen Dienste. Bei Position verfügbar, lautet der Zustand GPS=ERR;MODE=LAST. Ein Fehler der Wetterabfrage wird im Protokoll vereinfachend als NET=ERR dargestellt; das Feld kennzeichnet damit die Verfügbarkeit der Wetterdaten und nicht ausschließlich die physische Netzwerkkonnektivität. Die XOR-Prüfsumme wird über die ASCII-Bytes vor dem Stern berechnet:

```python
def checksum_xor(text: str) -> int:
    value = 0
    for byte in text.encode("ascii"):
        value ^= byte
    return value

frame = f"{payload}*{checksum_xor(payload):02X}\\n"
```

Der Dienst durchsucht mehrere Antwortzeilen, weil der STM32 vor dem finalen PONG oder OK zusätzliche Diagnosemeldungen wie RPI\_LINK\_RECOVERED ausgeben kann. Bleibt die Bestätigung aus, wird der Rahmen einmal wiederholt; anschließend wird der Fehler protokolliert, ohne den Prozess zu beenden.

// Vorlage: PDF-Seite 32
== systemd-Integration <sec-4-3>

Die zentralen Service-Parameter sind in Quelltext 4.3 zusammengefasst. Alle drei Dienste verwenden denselben Neustart- und Watchdog-Ansatz. Ein gemeinsames weather.target startet und stoppt die drei Prozesse als Gruppe, ohne ihre individuelle Steuerbarkeit aufzuheben. Quelltext 4.3: Wesentliche Einstellungen eines Dienstes

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

Die Anwendung liest das von systemd gesetzte WATCHDOG\_USEC und sendet das Lebenszeichen typischerweise nach der halben erlaubten Zeit. Die Keepalive-Funktion wird auch während kontrollierter Wartezeiten aufgerufen, damit ein langer I/O-Timeout nicht fälschlich als Prozess-Hänger gilt. Die Semantik von WATCHDOG=1 entspricht der offiziellen systemd-API \[7, Abschn. WatchdogSec=, 8, Abschn. WATCHDOG=1\].

// Vorlage: PDF-Seite 33
== Hardware-Watchdog des Raspberry Pi <sec-4-4>

systemd übernimmt zusätzlich die periodische Aktualisierung von /dev/watchdog0. Die Einstellung RuntimeWatchdogSec= ist in der systemd-Systemkonfiguration dokumentiert \[20, Abschn. RuntimeWatchdogSec=\]; die Kommunikation mit dem Gerät folgt der Linux- Watchdog-API \[3, Abschn. „The simplest API“\]. Der Versuch verwendet den BCM2835- Watchdog. In der Konfiguration wurde RuntimeWatchdogSec=10s angefordert;

der aktive Treiber meldete jedoch einen wirksamen Hardware-Timeout von 60 s; der protokollierte wdctl-Auszug ist in Quelltext C.6 wiedergegeben. Der Kernel- Panic-Test prüft nicht nur die Existenz des Geräts, sondern die vollständige Kette aus ausbleibendem Keepalive, Hardware-Reset, Linux-Boot und automatischem Dienststart.

// Vorlage: PDF-Seite 33
== STM32-Firmwarestruktur <sec-4-5>

Die Firmware ist CMSIS-basiert und in Treiber-, Diagnose- und Anwendungsmodule zerlegt. Zu den Modulen gehören Systemzeit, UART, I2C, LCD2004, Nachrichtenparser, Supervisor, Power-Monitor, Bootdiagnose und IWDG. CMSIS stellt die standardisierten Cortex-M- Kern- und Registerdefinitionen bereit \[21, Abschn. „CMSIS-Core“\]; die Peripherieregister werden direkt konfiguriert.

// Vorlage: PDF-Seite 33
=== Bootablauf und Diagnose <sec-4-5-1>

Nach dem Reset werden Takt, SysTick, UART, I2C, Power-Monitor und Supervisor initialisiert. Die Bootdiagnose prüft I2C/LCD, UART-Kommunikation und den Watchdog. Zusätzlich werden RCC-Resetflags gelesen und anschließend gelöscht. Die Diagnose unterscheidet unter anderem Pin-, Software- und IWDG-Reset. Erst nach Abschluss wechselt der Supervisor vom Boot- in den Laufzeitmodus.

#vorlage("abb-4-1.png", "Abbildung 4.1: Vereinfachter Boot- und Recovery-Ablauf des STM32", art: "image")

// Vorlage: PDF-Seite 34
=== Supervisor und Gesundheitsmodell <sec-4-5-2>

Der Supervisor verwaltet BOOT, MAIN\_LOOP, UART\_DRIVER, LCD\_DRIVER, RPI\_LINK und POWER\_SUPPLY. Jeder Eintrag enthält Aktivierung, Kritikalität, Gesundheitszustand und Zeitpunkt des letzten Fortschritts. Für kritische Subsysteme gelten Laufzeitgrenzen von typischerweise 3 s; der Raspberry-Pi-Link und das LCD sind nicht kritisch für den IWDG- Refresh. Der globale Modus wird aus den Einzelzuständen abgeleitet. Bei einem bestätigten nicht kritischen Fehler wechselt das System zu DEGRADED. Kritische Fehler verhindern die Freigabe des IWDG-Lebenszeichens. Diagnosebefehle liefern Alter, Zustand und Kritikalität der Subsysteme sowie kumulative Fehler- und Recovery-Zähler. Zusammen mit den Restart- und Watchdog-Zuständen von systemd realisiert diese Logik den in Abbildung 3.4 spezifizierten systemweiten Automaten verteilt über beide Plattformen.

// Vorlage: PDF-Seite 34
=== Independent Watchdog <sec-4-5-3>

Der IWDG wird mit dem LSI-Oszillator betrieben. Im Normalbetrieb erfolgt ein Refresh nur, wenn supervisor\_all\_critical\_ok() wahr ist. Damit ist die Watchdog- Aktualisierung an den Fortschritt der kritischen Funktionspfade und nicht nur an einen periodischen Interrupt gekoppelt. Der Diagnosebefehl HANG bestätigt zunächst mit HANGING, setzt eine verkürzte IWDG- Periode und verbleibt anschließend absichtlich in einer Endlosschleife. Nach dem Reset weist die Bootdiagnose den IWDG als Ursache aus. Der Testpfad ist ausschließlich für die Evaluation vorgesehen.

// Vorlage: PDF-Seite 35
=== UART-Empfang und Fehlergrenzen <sec-4-5-4>

Die UART-Routine arbeitet nicht blockierend und besitzt eine feste Rahmenlänge. Bei Überschreitung wird der laufende Rahmen verworfen und ERR:BUFFER gesendet. Ein vollständiger Wetterrahmen wird erst nach Prüfung des Stern-Trennzeichens und der XOR- Prüfsumme geparst. Ein Fehler führt zu ERR:CHECKSUM; ein gültiger Rahmen zu OK. Die Tests U1 und U2 prüfen zusätzlich, ob nach dem Fehler sofort wieder ein PING und ein gültiger Wetterrahmen verarbeitet werden können. Damit wird nicht nur die Erkennung, sondern auch die Wiederherstellung der Parser-Synchronisation bewertet.

// Vorlage: PDF-Seite 35
=== LCD- und I2C-Recovery <sec-4-5-5>

Die LCD-Gesundheit wird jede Sekunde geprüft. Einzelne Fehlschläge ändern den Zustand noch nicht; erst drei aufeinander folgende Fehler bestätigen den Ausfall. Der Treiber begrenzt I2C-Wartezeiten, setzt die Peripherie zurück und kann bis zu neun SCL-Pulse zur Busfreigabe erzeugen. Bei bestätigtem Ausfall wird LCD\_DRIVER=FAIL und der globale Modus DEGRADED gesetzt.

Nach drei erfolgreichen Proben wird das LCD neu initialisiert, der Recovery- Zähler erhöht und der Modus wieder zu NORMAL geändert. Die Konfiguration RESET\_AFTER\_LCD\_STABLE\_RECOVERY=0 stellt sicher, dass die Wiederkehr des nicht kritischen Displays keinen vollständigen Mikrocontroller-Reset auslöst.

// Vorlage: PDF-Seite 35
=== Spannungsüberwachung <sec-4-5-6>

Der STM32-PVD und ein Supervisor-Eintrag POWER\_SUPPLY sind in der Firmware vorbereitet. Die Zustandsänderung wird entprellt und kann als kritisch bewertet werden. Ergänzend wurde das Verhalten der vollständigen Nucleo-Platine bei schrittweise abgesenkter VIN-Spannung untersucht.

Reaktive Verfahren wie Hibernus verwenden eine Spannungsschwelle oberhalb des nicht mehr sicheren Betriebsbereichs, damit vor dem eigentlichen Brown-out noch genügend Restenergie für eine definierte Zustandsaktion verbleibt \[26, S. 15–17\].

// Vorlage: PDF-Seite 35
== Diagnose, Logs und Reproduzierbarkeit <sec-4-6>

Die Linux-Dienste schreiben Ereignisse in das systemd-Journal und Status in JSON- Dateien. Der STM32 liefert textbasierte Diagnosen über UART. Die Testskripte sichern vor jeder Fehlerinjektion einen Journal-Cursor und speichern Konsolenausgabe, Rohlogs, CSV-Einzelwerte und statistische Zusammenfassungen in testfallspezifischen Verzeichnissen. Das vollständige Evaluationsverzeichnis wurde anschließend archiviert und mit SHA-256 versehen.
