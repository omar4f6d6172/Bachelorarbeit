#import "../layout.typ": *

= Systementwurf und Implementierung <sec-3>

Dieses Kapitel führt Anforderungen, Entwurfsentscheidungen und deren konkrete Umsetzung in einer gemeinsamen Struktur zusammen. Die Darstellung folgt dabei zwei gekoppelten Pfaden: dem Nutzdatenpfad von der Positionserfassung bis zur LCD-Ausgabe und dem Überwachungs- und Recoverypfad von der lokalen Fehlererkennung bis zum Plattform-Reset. Für jedes Teilsystem werden Rolle, Schnittstellen, Implementierung, Gesundheitskriterien und Eskalationsgrenze gemeinsam beschrieben.

== Anwendungsfall und Systemgrenze <sec-3-1>

Als Testumgebung wird ein eingebettetes System verwendet, das seine Position über einen Binghe VK-162 USB-GPS-Empfänger bestimmt, Wetterdaten für diese Position von einem externen Dienst abruft und die Informationen auf einem LCD darstellt. Der Raspberry Pi übernimmt netzwerk- und betriebssystemnahe Aufgaben. Der STM32 übernimmt die hardwarenahe Displaysteuerung und eine unabhängige Überwachung der Mikrocontroller-Firmware. Der Datenfluss umfasst GPS-Erfassung, Wetterabfrage, UART-Übertragung und Anzeige. Die Fehlerdomänen und Schnittstellen sind in #ref(<abb-3-1>, supplement: [Abbildung]) dargestellt.

#vorlage("abb-3-1.png", "Gesamtarchitektur und wesentliche Datenpfade des Versuchssystems")

Der Anwendungsfall wurde gewählt, weil er mehrere voneinander unabhängige Fehlerquellen in einem überschaubaren Aufbau vereint. Die wissenschaftliche Fragestellung betrifft nicht das Anzeigen von Wetterdaten, sondern die Überwachung und Wiederherstellung des vollständigen Datenpfads.

== Anforderungen und Fehlermodell

Die Anforderungen definieren zunächst die erwartete Nutzfunktion und die für eine robuste Ausführung maßgeblichen Qualitätsmerkmale. Das anschließende Fehlermodell ordnet diesen Anforderungen konkrete Fehlerklassen, Erkennungsmechanismen und Recovery-Maßnahmen zu.

=== Funktionale Anforderungen <sec-3-2>

#include "../tabellen/tab-3-1.typ"

=== Nichtfunktionale Anforderungen <sec-3-3>

#include "../tabellen/tab-3-2.typ"

=== Fehlermodell <sec-3-4>

Das Fehlermodell umfasst Fehler auf Daten-, Komponenten-, Prozess-, Firmware- und Systemebene. Für jede Fehlerklasse werden Erkennung und Recovery bereits im Systementwurf festgelegt.

#include "../tabellen/tab-3-3.typ"

Allgemeine Netzwerkkonnektivität und Verfügbarkeit des Wetterdienstes sind unterschiedliche Fehlerquellen. Das Fehlermodell trennt sie deshalb einschließlich der jeweils angemessenen Recovery. Der Prototyp erfasst diese Ursachen jedoch nicht unabhängig: Ein fehlgeschlagener Abruf wird in beiden Fällen auf denselben Status abgebildet. Dieser Status belegt nur, dass aktuell kein gültiger Wetterdatensatz vorliegt; er ist kein Nachweis für einen Ausfall des Netzwerks. Die Implementierungsgrenze wird in #ref(<sec-4-2-4>, supplement: [Abschnitt]) erläutert.

== Gesamtarchitektur und Hardware <sec-3-5>

Die Gesamtarchitektur wird aus zwei gekoppelten Perspektiven beschrieben. Der Nutzdatenpfad führt von der Positionserfassung über Wetterabfrage und UART-Übertragung bis zur LCD-Ausgabe. Parallel dazu bewertet der Überwachungs- und Recoverypfad Lebenszeichen, Kommunikationszustände und lokale Fehler. Er hält eine Recovery möglichst innerhalb der betroffenen Komponente und eskaliert erst, wenn diese lokale Behandlung nicht ausreicht. Auf diese Weise werden die in #ref(<sec-3-4>, supplement: [Abschnitt]) eingeführten Fehlerklassen den Stufen des Datenpfads und ihren zuständigen Recovery-Ebenen zugeordnet.

=== Ende-zu-Ende-Datenpfad und Verantwortungsgrenzen <sec-3-5-1>

Die Gesamtfunktion entsteht in vier aufeinanderfolgenden Stufen: Der GPS-Dienst erzeugt zunächst einen Positionszustand. Der Wetterabrufdienst reichert ihn mit Wetterdaten an. Der UART-Dienst verdichtet beide Zustände zu einem seriellen Rahmen und überträgt ihn über die Plattformgrenze. Der STM32 prüft den Rahmen, aktualisiert die Anzeige und meldet das Verarbeitungsergebnis zurück. Jede Stufe besitzt damit einen definierten Eingang, einen Ausgang und eine eigene Fehlergrenze. #ref(<tab-3-4>, supplement: [Tabelle]) fasst diese Zuordnung zusammen.

#include "../tabellen/tab-3-4.typ"

Die Überwachung bildet keine zusätzliche Stufe des Nutzdatenpfads, sondern liegt quer dazu. systemd überwacht die drei Linux-Dienste einzeln, der STM32-Supervisor überwacht die hardwarenahen Funktionen, und die Hardware-Watchdogs beider Plattformen bilden die jeweils letzte Eskalationsebene. Dadurch lässt sich jede Komponente sowohl ihrem Beitrag zur Nutzfunktion als auch der für sie zuständigen Recovery-Ebene zuordnen.

=== Physischer Aufbau und Plattformgrenzen <sec-4-1>

Der Hardwareaufbau setzt den in #ref(<abb-3-1>, supplement: [Abbildung]) beschriebenen Datenpfad physisch um. Der GPS-Empfänger ist über USB mit dem Raspberry Pi verbunden. Dort erscheint er über die Geräteklasse USB-CDC als virtuelle serielle Schnittstelle /dev/ttyACM0 und liefert NMEA-Datensätze mit 9.600 Bd; die Einheit Baud bezeichnet dabei die Symbolrate.

Für die Weitergabe an den STM32 wird auf dem Raspberry Pi /dev/serial0 und auf dem STM32 das serielle Hardwaremodul USART1 verwendet. PA9 dient dabei als Sendeleitung (TX), PA10 als Empfangsleitung (RX). Die Verbindung arbeitet mit 115.200 Bd im Format 8N1, also mit acht Datenbits, ohne Paritätsbit und mit einem Stoppbit.

Der STM32 steuert das LCD2004 über I2C1 an den Pins PB6 und PB7 an. SCL führt dabei den Takt und SDA die Daten. Die Einstellung Alternate Function ordnet die Pins der jeweiligen Peripheriefunktion anstelle der allgemeinen Ein-/Ausgabefunktion zu; die Open-Drain-Ausgänge verwenden die gemeinsamen Pull-up-Widerstände der Busleitungen. Der LCD-Adapter wurde ausschließlich mit der 7-Bit-Adresse 0x27 bei einer Busfrequenz von 100 kHz betrieben. Als Systemtakt dient der interne 16-MHz-Hochgeschwindigkeitsoszillator HSI16. Die Registerkonfiguration orientiert sich am STM32-Referenzhandbuch \[#quelle(<lit-04>), S. 1151-1183, Abschn. 38.1-38.4.10\]. #ref(<tab-4-1>, supplement: [Tabelle]) fasst die Anschlüsse und Konfigurationswerte zusammen.

#echtetabelle("Wesentliche Schnittstellen und Konfigurationswerte", key: <tab-4-1>, (1.3fr, 1.4fr, 2.4fr), ([Funktion], [Anschluss], [Konfiguration],), (
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

// Komponentenorientierte Fortsetzung desselben Kapitels.
#include "04.typ"
