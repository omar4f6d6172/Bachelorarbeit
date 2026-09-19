#import "../layout.typ": *

// Vorlage: PDF-Seite 13
= Theoretische Grundlagen <sec-2>

// Vorlage: PDF-Seite 13
== Eingebettete Systeme und heterogene Fehlerdomänen <sec-2-1>

Ein eingebettetes System ist in eine technische Umgebung integriert und stellt eine spezialisierte Funktion bereit. In einem heterogenen Aufbau können ein Linux-Rechner, ein Mikrocontroller, Kommunikationsschnittstellen und externe Dienste gleichzeitig beteiligt sein. Diese Teile besitzen unterschiedliche Laufzeitmodelle und Fehlermechanismen. Ein Linux-Dienst kann abstürzen oder blockieren, ein Mikrocontroller kann in einer Endlosschleife verbleiben, eine serielle Verbindung kann Daten verlieren und ein externer Dienst kann zeitweise nicht erreichbar sein. Für die Fehlerbehandlung ist deshalb die Definition von Fehlerdomänen hilfreich. Eine Fehlerdomäne umfasst Komponenten, die durch dieselbe Fehlerursache gemeinsam ausfallen können. Ein Software-Watchdog im Linux-Prozess ist gegenüber Kernel-Hängern nicht unabhängig \[#quelle(<lit-03>), Abschn. „The simplest API“\]. Der IWDG des STM32 arbeitet unabhängig von Hauptschleife und Haupttakt, da ihn der separate LSI-Oszillator taktet \[#quelle(<lit-04>), S. 1037-1045, Abschn. 33\].

// Vorlage: PDF-Seite 13
== Dependability und Robustheit <sec-2-2>

Avizienis et al. fassen unter Dependability Eigenschaften zusammen, die ein begründetes Vertrauen in einen Dienst ermöglichen. Dazu gehören Verfügbarkeit, Zuverlässigkeit, Safety, Integrität und Wartbarkeit \[#quelle(<lit-01>), S. 13-14\]. Für die vorliegende Arbeit wird Robustheit operational durch folgende Eigenschaften beschrieben:

+ Ein Fehler wird in einem nachvollziehbaren Zeitfenster erkannt.

+ Der Fehler wird in einen definierten internen und extern sichtbaren Zustand übersetzt.

+ Nicht betroffene Komponenten bleiben nach Möglichkeit aktiv.

+ Eine zur Fehlerklasse passende Recovery-Maßnahme wird ausgeführt.

+ Die Rückkehr zu einer funktionsfähigen Konfiguration ist durch Logs, Statusdateien oder Diagnosemeldungen nachweisbar. Robustheit ist damit nicht gleichbedeutend mit vollständiger Fehlertransparenz. Ein sichtbarer Zustand wie NET=ERR kann robuster sein als die unmarkierte Darstellung veralteter Wetterwerte, weil die Datenqualität korrekt kommuniziert wird.

// Vorlage: PDF-Seite 14
== Fault, Error und Failure <sec-2-3>

Die Dependability-Taxonomie unterscheidet eine Kette aus Fault, Error und Failure \[#quelle(<lit-01>), S. 13 und 20–22\]. Ein Fault ist die Ursache, etwa eine getrennte SDA-Leitung oder ein blockierter Prozess. Der Fault kann einen fehlerhaften internen Zustand erzeugen, beispielsweise ein I2C-NACK oder einen veralteten JSON-Zustand. Wird die geforderte Funktion an der Systemgrenze nicht mehr erbracht, liegt ein Failure vor. Diese Trennung ist für die Evaluation wesentlich. Das Abziehen des GPS-Empfängers ist die Fehlerinjektion. have\_fix=false ist ein interner Fehlerzustand. Die Übertragung von GPS=ERR;MODE=LAST ist dagegen eine kontrollierte Reaktion, die einen unmarkierten Ausfall der Gesamtfunktion verhindert.

Unterspannung, Brown-out und intermittierende Versorgung. Ein Brown-out ist kein zwingend vollständiger Spannungsverlust, sondern ein Betriebszustand, in dem die Versorgung unter den für zuverlässige Ausführung erforderlichen Bereich absinkt. Balsamo et al. unterscheiden bei intermittierender Versorgung eine minimale Betriebsspannung sowie getrennte Schwellen für Hibernation und Wiederaufnahme; unterhalb der minimalen Spannung kann ein Prozessor unvorhersehbar arbeiten oder vollständig abschalten \[#quelle(<lit-26>), S. 15–16\]. Ein beobachteter Neustart bei einer am Netzteil eingestellten Spannung ist deshalb nicht automatisch mit der internen BOR-Schwelle des Mikrocontrollers gleichzusetzen.

Forschung zu intermittierend versorgten eingebetteten Systemen zeigt außerdem, dass wiederholte Spannungsausfälle nicht nur Verfügbarkeit, sondern auch Zustandskonsistenz betreffen. Mementos misst die verfügbare Energie und sichert den Ausführungszustand vor einem erwarteten Spannungsverlust in nichtflüchtigem Speicher \[#quelle(<lit-27>), S. 159–163\]. DINO zeigt, dass Neustarts an beliebigen Programmpunkten zu teilweise oder wiederholt ausgeführten Operationen und damit zu inkonsistenten Zuständen führen können \[#quelle(<lit-28>), S. 575–577\]. Die vorliegende Arbeit implementiert kein solches Checkpointing; die Arbeiten dienen als theoretische Grundlage für die Trennung von Spannungserkennung, definiertem Zustand, Neustart und anschließender Recovery.

// Vorlage: PDF-Seite 14
== Fehlerbehandlung als Folge von Phasen <sec-2-4>

Eine vollständige Fehlerbehandlung besteht aus mehreren Phasen:

Erkennung: Ein Timeout, eine Ausnahme, ein ungültiger Datenrahmen oder ein Hardwarestatus signalisiert eine Abweichung.

Eingrenzung: Die betroffene Fehlerdomäne wird bestimmt, damit funktionierende Komponenten nicht unnötig zurückgesetzt werden.

Bewertung: Kritikalität, Alter des Zustands und Anzahl aufeinander folgender Fehler werden berücksichtigt.

Recovery: Retry, Reinitialisierung, Dienstneustart, Reset oder Reboot stellen einen definierten Zustand her.

Verifikation: Die ursprüngliche Funktion wird erneut geprüft; ein Prozess gilt nicht bereits durch seine Existenz als funktional. Die Phasenfolge wird in dieser Arbeit als projektspezifische Struktur verwendet. Sie knüpft an Randells Trennung von Fehlererkennung, Zustandswiederherstellung und alternativer Ausführung an \[#quelle(<lit-05>), S. 220-223\].

// Vorlage: PDF-Seite 15
== Recovery-orientierter Entwurf <sec-2-5>

Recovery-Oriented Computing betrachtet Hardwarefehler, Softwarefehler und Bedienfehler als unvermeidbare Ereignisse und richtet den Entwurf stärker auf eine kurze Mean Time to Repair aus \[#quelle(<lit-02>), S. 1 und 5\]. Dazu gehören gezielte Recovery-Experimente, Partitionierung von Fehlerdomänen, Defense in Depth und die Beobachtbarkeit von Reparaturmechanismen. Die Idee feingranularer Recovery wird durch Microreboots konkretisiert: Anstatt eine gesamte Anwendung zurückzusetzen, wird möglichst nur die fehlerhafte Komponente neu gestartet \[#quelle(<lit-06>), S. 31–32\]. Dieses Prinzip lässt sich auf die vorliegende Arbeit übertragen. Ein abgestürzter GPS-Dienst wird einzeln neu gestartet; ein LCD-Fehler wird lokal behandelt; ein vollständiger Raspberry-Pi-Neustart bleibt die letzte Eskalationsstufe.

// Vorlage: PDF-Seite 15
== Grundprinzip eines Watchdogs <sec-2-6>

Ein Watchdog erwartet ein periodisches Lebenszeichen innerhalb eines vorgegebenen Zeitfensters. Bleibt das Lebenszeichen aus, löst er eine vordefinierte Aktion aus \[#quelle(<lit-07>), Abschn. WatchdogSec=, #quelle(<lit-08>), Abschn. WATCHDOG=1, #quelle(<lit-04>), S. 1037–1045, Abschn. 33\]. Das Lebenszeichen muss den Fortschritt der überwachten Funktion repräsentieren. Wird ein Hardware-Watchdog bedingungslos in einem Timer-Interrupt aktualisiert, kann eine blockierte Hauptschleife unentdeckt bleiben \[#quelle(<lit-11>), S. 6-7\]. Ein Watchdog erkennt primär Zeitüberschreitungen, nicht automatisch die semantische Korrektheit. Eine fehlerhafte, aber weiterhin schnell laufende Schleife kann den Timer fristgerecht bedienen. Deshalb ergänzt der STM32-Supervisor die reine Zeitüberwachung um Gesundheitszustände mehrerer Subsysteme.

// Vorlage: PDF-Seite 15
== Watchdog-Ebenen <sec-2-7>

// Vorlage: PDF-Seite 15
=== Anwendungs- und Kommunikationsüberwachung <sec-2-7-1>

Auf Anwendungsebene werden Ausnahmen, Zustandsalter, Prüfsummen und Heartbeat-Nachrichten verwendet. Diese Mechanismen können differenzierte Fehlerzustände erzeugen und lokale Recovery auslösen. Sie fallen jedoch aus, wenn die gesamte Ausführungsumgebung blockiert.

// Vorlage: PDF-Seite 15
=== Service-Watchdog <sec-2-7-2>

Ein Service-Manager kann Prozesse überwachen. Bei systemd aktiviert WatchdogSec= einen Dienst-Watchdog. Der Dienst muss periodisch WATCHDOG=1 über sd\_notify() senden; bleibt die Nachricht aus, behandelt der Service-Manager den Dienst als fehlerhaft \[#quelle(<lit-07>), Abschn. WatchdogSec= und Restart=, #quelle(<lit-08>), Abschn. WATCHDOG=1\]. In Verbindung mit Restart= entsteht eine Recovery für Prozesse, die formal existieren, aber keinen Fortschritt mehr machen.

// Vorlage: PDF-Seite 16
=== Mikrocontroller-Watchdog <sec-2-7-3>

Der STM32L432KC besitzt einen Independent Watchdog, der aus dem Low-Speed-Internal-Oszillator getaktet wird und einen Reset auslöst, wenn der Zähler nicht rechtzeitig aktualisiert wird \[#quelle(<lit-04>), S. 1037–1045, Abschn. 33, #quelle(<lit-09>), S. 30 und 41\]. Die unabhängige Taktquelle reduziert gemeinsame Fehlerursachen mit dem Haupttakt. Ein Window Watchdog kann darüber hinaus auch ein zu frühes Lebenszeichen als Fehler erkennen; er wurde in der Arbeit nicht verwendet.

// Vorlage: PDF-Seite 16
=== Systemweiter Hardware-Watchdog <sec-2-7-4>

Linux stellt Hardware-Watchdogs über die Watchdog-API und Geräte wie /dev/watch dog0 bereit \[#quelle(<lit-03>), Abschn. „The simplest API“\]. Solange ein Userspace-Prozess den Timer innerhalb des vorgegebenen Zeitfensters aktualisiert, bleibt das System aktiv. Bei einem schweren Hänger läuft der Timer ab und die Hardware löst einen Neustart aus. Diese Ebene schützt gegen Fehler, die ein Service-Watchdog in PID 1 nicht mehr behandeln kann.

// Vorlage: PDF-Seite 16
== Timeout-Dimensionierung <sec-2-8>

// VORLAGE PDF S. 16: Satz am rechten Seitenrand abgeschnitten (gültige/gültigen).
Die Dimensionierung eines Watchdog-Timeouts ist zunächst ein allgemeines Entwurfsproblem. Der Timeout muss größer sein als der größte im fehlerfreien Betrieb erwartete Abstand zwischen zwei gültigen Fortschrittsmeldungen. Zusätzlich sind zeitliche Schwankungen durch Scheduling, Interrupts und asynchrone Kommunikation sowie eine Sicherheitsreserve zu berücksichtigen \[#quelle(<lit-10>), S. 4 und 12\] \[#quelle(<lit-11>), S. 16\].

// Formeln sind aus den sichtbaren Formeln der Vorlage nativ nachgesetzt.
Dabei bezeichnet T\_WDT den Watchdog-Timeout, T\_max,normal den größten erwarteten Abstand zwischen zwei zulässigen Keepalives, T\_Jitter die zusätzliche zeitliche Schwankung und T\_Reserve eine Sicherheitsmarge. Daraus ergibt sich als vereinfachte Entwurfsregel:

#gleichung($T_"WDT" >= T_("max, normal") + T_"Jitter" + T_"Reserve"$, <eq-2-1>)

Die Beziehung ist keine Normformel und kein formaler WCET-Nachweis, sondern beschreibt die allgemeine Dimensionierungslogik dieser Arbeit. Ein langer Timeout reduziert Fehlalarme, verlängert aber die Reaktion auf echte Hänger; ein kurzer Timeout reagiert schneller, kann bei hoher Last oder blockierendem I/O unnötige Neustarts auslösen. Die konkreten Timeout-Werte des aufgebauten Systems werden erst in #ref(<sec-4>, supplement: [Kapitel]) festgelegt.

// Vorlage: PDF-Seite 17
== Heartbeat und Supervisor <sec-2-9>

Ein Heartbeat ist ein Lebenszeichen zwischen Komponenten. Das PING/PONG-Verfahren dieser Arbeit prüft den vollständigen Anwendungsdatenpfad: Empfang, Parsing, Verarbeitung und Antwort. Ein Supervisor aggregiert mehrere Gesundheitsinformationen. Neben einem Zeitstempel kann er Kritikalität, Fehlerbestätigungen, Recovery-Zähler und den globalen Systemmodus speichern. Mehrfachabtastungen vermeiden, dass ein einzelner transienter Fehler sofort zu einer Zustandsänderung führt. Der STM32 bestätigt LCD-Fehler und -Wiederherstellungen jeweils erst nach mehreren aufeinander folgenden Messungen. Kritische Subsysteme beeinflussen die Freigabe des IWDG-Refresh; ein nicht kritischer Displayfehler führt lediglich zum Zustand DEGRADED.

// Vorlage: PDF-Seite 17
== Datenintegrität serieller Kommunikation <sec-2-10>

UART liefert einen Bytestrom ohne inhärente Rahmen- oder Integritätsgarantie. Ein Anwendungsprotokoll benötigt deshalb eine Rahmengrenze, eine maximale Länge und eine Prüfinformation. Die Arbeit verwendet eine ASCII-Zeile mit XOR-Prüfsumme. XOR ist einfach und schnell, erkennt aber deutlich weniger Fehlermuster als gut ausgewählte CRC-Verfahren \[#quelle(<lit-12>), S. 59–60 und 67–69, #quelle(<lit-13>), S. 145–146\].

// Vorlage: PDF-Seite 18
== I2C und lokale Bus-Recovery <sec-2-11>

I2C verwendet Open-Drain-Leitungen und adressierte Transfers. Die offizielle Spezifikation beschreibt unter anderem START/STOP-Bedingungen, Acknowledgements und das Bus-Clear-Verfahren \[#quelle(<lit-14>), Abschn. 3.1.1, 3.1.4-3.1.6, 3.1.16\]. Bleibt eine Peripherie oder Leitung in einem fehlerhaften Zustand, darf eine blockierende BUSY-Prüfung die Anwendung nicht dauerhaft anhalten. Die Arbeit begrenzt Wartezeiten, setzt den I2C-Block zurück und erzeugt bei Bedarf Taktpulse zur Busfreigabe, bevor das LCD neu initialisiert wird. Das angeschlossene LCD2004-Zeichenmodul wird über den Adapter als HD44780-basiertes Display angesteuert \[#quelle(<lit-19>), S. 4\]. Der eingesetzte AZDelivery-I2C-Adapter verwendet einen PCF8574-I/O-Expander \[#quelle(<lit-19>), S. 4\]. Die Eigenschaften und der hardwareseitig einstellbare Adressbereich des Expanders sind im NXP-Datenblatt dokumentiert \[#quelle(<lit-15>), S. 1 und 5-8\].

// Vorlage: PDF-Seite 18
== GPS, NMEA und externe Wetterdaten <sec-2-12>

Als vollständiges USB-GPS-Gerät wurde ein unter der Vertriebsbezeichnung Binghe VK-162 erworbenes Modul eingesetzt. Das Gerät erschien unter Linux als /dev/ttyACM0. Seine interne Empfängereinheit identifizierte sich in den protokollierten USB- und Startmeldungen als Hardware der u-blox-7-Familie beziehungsweise als UBX-G70xx; diese Bezeichnung beschreibt die intern erkannte Einheit und nicht die Vertriebsbezeichnung des vollständigen USB-Geräts. Die experimentelle Identifikation ist in Anhang A dokumentiert. Die interne Empfängereinheit liefert NMEA-Datensätze über USB. Der RMC-Satz enthält Zeit, Status, Position und Bewegungsinformationen; nur der Status A kennzeichnet gültige Navigationsdaten \[#quelle(<lit-16>), S. 62\]. Die Umrechnung von Grad und Minuten in Dezimalgrad erfolgt nach

#gleichung($phi_"dez" = phi_"Grad" + frac(phi_"Minuten", 60)$, <eq-2-2>)

Der Wetterdienst wird über eine HTTPS-Schnittstelle mit JSON-Antwort angesprochen \[#quelle(<lit-17>), Abschn. "Weather Forecast API"\]. Als externe Abhängigkeit ist er bewusst Teil des Fehlermodells: Netzwerkkonnektivität, DNS/TLS und die Verfügbarkeit beziehungsweise Antwort des Wetterdienstes können unabhängig voneinander ausfallen.

// Vorlage: PDF-Seite 18
== Messung von Recovery-Zeiten <sec-2-13>

Für Zeitdifferenzen innerhalb eines laufenden Linux-Systems ist eine monotone Zeitquelle erforderlich, weil die Echtzeituhr durch NTP oder einen manuellen Abgleich springen kann. Die Testskripte verwenden daher time.monotonic(). Bei vollständigen Neustarts ist eine externe Messinstanz notwendig, da der zu untersuchende Rechner während des Ausfalls keine kontinuierliche Zeitreihe schreiben kann. Bei kleinen Stichproben werden Mittelwert, Median, Minimum, Maximum und Stichproben-Standardabweichung berichtet.

// Vorlage: PDF-Seite 19
== Zwischenfazit <sec-2-14>

Keine einzelne Watchdog-Ebene deckt alle Fehlerklassen ab. Datenfehler, Peripheriefehler, Prozess-Hänger, Firmware-Hänger und Kernel-Hänger benötigen unterschiedliche Erkennungs- und Recovery-Mechanismen. Daraus wird im folgenden Kapitel eine hierarchische Architektur abgeleitet, die lokal beginnt und nur bei schwerwiegenden Fehlern bis zum vollständigen Systemneustart eskaliert.
