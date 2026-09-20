#import "../layout.typ": *

// Vorlage: PDF-Seite 61
= Fazit und Ausblick <sec-7>

// Vorlage: PDF-Seite 61
== Fazit <sec-7-1>

// VORLAGE PDF S. 61: Zwei Textlücken: nach belegte und nach untersuchten.
Diese Arbeit hat Watchdog- und Recovery-Strategien für ein heterogenes eingebettetes System aus Raspberry Pi und STM32 untersucht. Als Testanwendung wurde ein vollständiger Datenpfad aus GPS-Empfang, Wetterabfrage, UART-Kommunikation und LCD-Anzeige aufgebaut. Der Beitrag liegt nicht in der Wetteranwendung selbst, sondern in der Zuordnung von Fehlerklassen zu abgestuften Recovery-Mechanismen und deren experimenteller Bewertung. Die implementierte Architektur behandelt Datenfehler lokal, reinitialisiert nicht kritische Peripherie, verwendet bei externen Ausfällen einen degradierten Zustand, startet einzelne Linux-Dienste neu und eskaliert erst bei Firmware- oder System-Hängern zu IWDG-Reset beziehungsweise Hardware-Reboot. Die Aufteilung in getrennte systemd-Dienste begrenzt Fehlerdomänen; der STM32-Supervisor verknüpft den IWDG-Refresh mit dem Fortschritt kritischer Subsysteme. Innerhalb der untersuchten Stichprobe waren alle wiederholten funktionalen Recovery-Testfälle in fünf von fünf Durchläufen erfolgreich. Besonders deutlich war der Unterschied zwischen Prozess-Hänger und Prozessabsturz: Der hängende GPS-Dienst benötigte im Mittel 28,46 s, der abgestürzte Dienst 5,76 s bis zur funktionalen Wiederherstellung. Der STM32 kehrte nach einem absichtlichen Firmware-Hänger in 5,70 s zum Anwendungsmodus zurück. Der vollständige Spannungsverlust führte zu einer mittleren externen Netzwerk-Nichtverfügbarkeit von 32,33 s. Der ergänzende Unterspannungstest zeigte bei der Nucleo-Platine in fünf von fünf Durchläufen dieselbe stufenweise Degradation; auf dem Raspberry Pi belegte der Statuswert 0x50005 eine bei der untersuchten Versorgungssituation aktive Unterspannung und Drosselung. Für den in dieser Arbeit untersuchten Aufbau und die durchgeführten Versuche lassen sich die Forschungsfragen wie folgt beantworten: Fehler müssen auf der kleinsten noch funktionsfähigen Ebene erkannt und behandelt werden; feingranulare Recovery reduziert Zustandsverlust und Ausfallzeit; Hänger benötigen explizite Fortschrittsüberwachung; und die untersuchte unabhängige Watchdog-Kette führte bei den injizierten schweren Fehlern zur automatischen Rückkehr in einen definierten Zustand. Eine einzige Watchdog-Strategie ist für ein solches System nicht ausreichend.

// Vorlage: PDF-Seite 61
== Ausblick <sec-7-2>

Für eine Weiterentwicklung bieten sich an:

- quantitative Brown-out- und PVD-Versuche mit definierter Spannungsrampe, Oszilloskopmessung direkt an den Versorgungsschienen, Laststromaufzeichnung und protokollierten RCC-Resetflags,

- Langzeit- und Stresstests mit deutlich größerer Stichprobe,

- Einsatz eines Window Watchdogs zur Erkennung zu früher Lebenszeichen oder eines separaten externen Watchdog-Bausteins als zusätzliche unabhängige Überwachung,

- CRC für eine stärkere Fehlererkennung, Sequenznummern zur Erkennung verlorener oder wiederholter Rahmen und explizite Nachrichtenalterung gegen die Verwendung veralteter Daten im UART-Protokoll,

- getrennte Gesundheitszustände für Netzwerkpfad und Wetterdienst mit ursachenspezifischer Diagnose und Recovery sowie separaten Fehlerinjektionstests für Netzverlust, HTTP-Dienstfehler und ungültige API-Antworten,

- persistente Reset- und Fehlerzähler in einem verschleißbewusst beschriebenen Speicher,

- Read-only-Root-Dateisystem, Overlay-Dateisystem oder Energiepuffer, um unvollständige Schreibvorgänge und Dateisystemschäden auf der SD-Karte zu begrenzen,

- abgesicherter Bootloader mit signierten Firmware-Updates zur Authentizitätsprüfung und Rollback zur Rückkehr auf die letzte funktionsfähige Firmware,

- zentrale Telemetrie zur Sammlung von Zustandsdaten, automatisierte Alarmierung und Trendanalyse zur frühzeitigen Erkennung wiederkehrender Fehler,

- systematische Fault-Injection für Speicher-, Ressourcen- und Timingfehler.

Diese Erweiterungen würden die Übertragbarkeit auf produktive Systeme erhöhen, während das in der Arbeit untersuchte Grundprinzip erhalten bliebe: lokale Recovery zuerst, kontrollierte Eskalation nur bei Bedarf und unabhängige Überwachung für den Ausfall der jeweils darunterliegenden Ebene.
