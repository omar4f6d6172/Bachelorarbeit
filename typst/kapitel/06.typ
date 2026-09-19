#import "../layout.typ": *

// Vorlage: PDF-Seite 55
= Diskussion <sec-6>

Die folgenden Abschnitte interpretieren die in #ref(<sec-5>, supplement: [Kapitel]) berichteten Messwerte. Aussagen zur Wirksamkeit beziehen sich auf die vorliegende Arbeit, die beschriebenen Fehlerklassen und die durchgeführten Versuchsdurchläufe

#include "../tabellen/tab-6-1.typ"

// Vorlage: PDF-Seite 55
== Beantwortung der Forschungsfragen <sec-6-1>

// Vorlage: PDF-Seite 55
=== F1: Strukturierung und geeignete Fehlerdomäne <sec-6-1-1>

Die Versuche sprechen dafür, Fehler auf der niedrigsten Ebene zu behandeln, auf der noch eine funktionsfähige Ausführungsbasis vorhanden ist. Datenfehler werden im Parser verworfen, ein LCD-Fehler im Mikrocontroller lokal behandelt, Prozessfehler durch systemd und ein vollständiger Linux-Hänger durch den Hardware-Watchdog. Die Architektur folgt damit dem Recovery-orientierten Prinzip der Partitionierung und einer mehrstufigen Verteidigung \[#quelle(<lit-02>), S. 5 und 8\]. Die Trennung der Raspberry-Pi-Anwendung in drei Dienste war dafür zentral. Während eines Netzwerkfehlers blieben GPS-Erfassung und UART aktiv. Beim Neustart des GPS-Dienstes musste weder die Wetterlogik noch der serielle Link zurückgesetzt werden. Die Komponentengrenzen wurden somit zugleich zu Recovery- Grenzen.

// Vorlage: PDF-Seite 56
=== F2: Eingriffstiefe und Wiederherstellungszeit <sec-6-1-2>

Lokale Datenfehler wurden im Millisekundenbereich behandelt. Ein Dienstabsturz benötigte im Mittel 5,76 s, ein Dienst-Hänger 28,46 s. Der STM32-Firmware-Hänger führte nach 5,70 s zurück in den Anwendungsmodus. Vollständige Neustarts verursachten mit etwa 32 s bis 35 s die größte beobachtete Netzwerkunterbrechung. Diese Abstufung zeigt im untersuchten Aufbau, dass die Eingriffstiefe einen praktischen Einfluss auf die Ausfallzeit hat. Feingranulare Recovery erhält funktionsfähige Zustände und entspricht dem Grundgedanken eines Microreboots \[#quelle(<lit-06>), S. 31–32\]. Ein vollständiger Reset bleibt dennoch unverzichtbar, wenn die betroffene Fehlerdomäne selbst keine Recovery mehr ausführen kann.

// Vorlage: PDF-Seite 56
=== F3: Absturz, Hänger, Firmware-Hänger und System-Hänger <sec-6-1-3>

Ein Prozessabsturz ist für systemd sofort sichtbar. Die gemessene Wiederherstellung wurde deshalb im Wesentlichen von RestartSec=5s bestimmt. Ein mit SIGSTOP erzeugter Hänger ließ den Prozess dagegen formal bestehen. Erst das Ausbleiben von WATCHDOG=1 führte zum Timeout. Diese Differenz zeigt, weshalb eine Restart-Policy allein nicht gegen Hänger schützt. Beim STM32-Hänger blockierte die vollständige Firmwareausführung; der unabhängig getaktete IWDG blieb als Recovery-Basis erhalten. Beim Kernel-Panic konnte auch systemd nicht mehr reagieren. Erst der BCM2835-Hardware-Watchdog stellte das System wieder her. Die Versuche bilden damit eine Hierarchie zunehmend schwerer Fehlerdomänen ab.

// Vorlage: PDF-Seite 56
=== F4: Automatische Rückkehr zum definierten Zustand <sec-6-1-4>

Innerhalb des untersuchten Umfangs erreichten alle wiederholten funktionalen Recovery- Tests den vordefinierten Endzustand. Bei GPS und Netzwerk bedeutete dies nicht immer sofort den vollständigen Sollzustand: Das System wechselte zunächst in einen transparenten degradierten Zustand und kehrte nach Wegfall der Störung zu LIVE beziehungsweise NET=OK zurück. Auch Firmware- und Systemneustarts benötigten nach dem Reset keinen manuellen Start der Anwendung. Die Aussage ist auf die getesteten Fehlerklassen und die kleine Stichprobe beschränkt. Fünf erfolgreiche Durchläufe pro risikoarmem Testfall zeigen eine reproduzierbare Funktion innerhalb des untersuchten Aufbaus;

// Vorlage: PDF-Seite 57
== Dienst-Hänger gegenüber Dienst-Absturz <sec-6-2>

Der Vergleich S1/S2 ist der deutlichste quantitative Unterschied. Der hängende GPS- Dienst benötigte im Mittel 28,46 s, der abgestürzte Dienst 5,76 s. Der Hänger war damit ungefähr 4,9-mal langsamer wiederhergestellt. Der Unterschied ist kein Mangel der Restart-Policy, sondern eine Konsequenz der fehlenden unmittelbaren Beobachtbarkeit eines Hängers. Die erste S1-Wiederholung dauerte länger als die folgenden Läufe, weil die Fehlerinjektion zu einem anderen Zeitpunkt relativ zum letzten Keepalive erfolgte. Ein Watchdog- Timeout wird ab dem letzten akzeptierten Lebenszeichen berechnet und nicht ab dem extern beobachteten SIGSTOP.

// Vorlage: PDF-Seite 57
== Nutzen des degradierten Betriebs <sec-6-3>

Der GPS-Fallback und die LCD-Recovery zeigen, dass ein System trotz eines Teilausfalls noch einen sinnvollen Dienst bereitstellen kann. Bei fehlendem GPS-Empfänger wurden letzte bekannte Daten nur mit ausdrücklicher Kennzeichnung GPS=ERR;MODE=LAST weitergegeben. Der LCD-Ausfall beeinträchtigte nicht die UART- und Supervisorfunktion. Dadurch blieb das System diagnostizierbar und konnte die Wiederkehr der Komponente erkennen. Ein degradiertes Modell verlangt jedoch klare Semantik. Veraltete Daten dürfen nicht als aktuell erscheinen, und kritische Fehler dürfen nicht als nicht-kritisch eingestuft werden. In der Arbeit begrenzt MAX\_POSITION\_AGE\_SECONDS die Wiederverwendung einer letzten Position.

// Vorlage: PDF-Seite 57
== Lokale Recovery und Zustandsverlust <sec-6-4>

Eine Recovery setzt Zustände zurück. Je größer die Recovery-Domäne, desto mehr korrekter Zustand geht verloren. Ein vollständiger STM32-Reset hätte das LCD ebenfalls reinitialisiert, gleichzeitig aber UART-Puffer, Diagnosezustände und laufende Kommunikation unterbrochen. Die lokale I2C-/LCD-Reinitialisierung vermied diesen Kollateraleffekt. Dasselbe Prinzip gilt für Linux-Dienste. Die Zustandsdateien in tmpfs entkoppeln Prozesse, sind aber bewusst flüchtig. Nach einem vollständigen Reboot wird kein alter Zustand übernommen; dafür muss der Datenpfad neu aufgebaut werden. Diese Entscheidung bevorzugt Datenfrische gegenüber Persistenz.

// Vorlage: PDF-Seite 57
== Datenintegrität und Grenzen der XOR-Prüfsumme <sec-6-5>

U1 und U2 zeigen innerhalb der durchgeführten Versuche, dass die implementierten Grenzen greifen: Fehlerhafte Prüfsummen und übergroße Rahmen wurden in allen Wiederholungen abgelehnt, und die Kommunikation blieb anschließend synchron. Damit wurde der Schutz gegen die gezielt injizierten einfachen Fehler im Versuchssystem demonstriert. Die XOR-Prüfsumme darf jedoch nicht überinterpretiert werden. Sie erkennt beispielsweise bestimmte Mehrbitfehler nicht und bietet keinen Schutz gegen absichtliche Manipulation. Untersuchungen zu eingebetteten Prüfsummen zeigen die deutlich bessere Fehlererkennungsleistung geeigneter CRCs \[#quelle(<lit-12>), S. 59–60 und 67–69, #quelle(<lit-13>), S. 145–146\].

// Vorlage: PDF-Seite 58
== Trade-off der Watchdog-Zeiten <sec-6-6>

Die Timeout-Werte beeinflussen Verfügbarkeit und Fehlalarmrisiko. Ein kürzerer Service- Timeout hätte S1 und S3 beschleunigt, könnte aber bei langsamen Gerätezugriffen oder hoher Systemlast unnötige Neustarts erzeugen. Die Arbeit verwendet 30 s, während die normalen Dienstperioden bei 5 s beziehungsweise 10 s liegen. Für ein Produkt müssten Worst-Case-I/O-Zeiten, CPU-Last, Netzwerk-Timeouts und zulässige maximale Ausfallzeit gemeinsam betrachtet werden. Die Notwendigkeit, den Timeout aus dem zeitlichen Verhalten der gesamten überwachten Software abzuleiten, wird auch in der Watchdog-Literatur hervorgehoben \[#quelle(<lit-10>), S. 12\] \[#quelle(<lit-11>), S. 16\].

Auch beim Hardware-Watchdog dürfen Konfigurationswert und extern beobachtete Ausfallzeit nicht gleichgesetzt werden. wdctl meldete einen Timeout von 60 s; für P2 liegt jedoch nur eine zeitlich auswertbare externe Einzelmessung von 35 s vor. Der Watchdog lief bereits vor der Kernel-Panic und wurde periodisch aktualisiert. Zum Zeitpunkt der Fehlerinjektion konnte daher ein Teil des aktuellen 60 s-Intervalls bereits verstrichen sein. Die externe Messung begann außerdem erst mit dem ersten fehlgeschlagenen Ping und nicht exakt mit der Kernel-Panic. Der Wert von 35 s enthält die verbleibende Watchdog- Zeit, Reset, Bootvorgang und Netzwerkinitialisierung. Er beschreibt ausschließlich die in diesem einen Durchlauf beobachtete End-to-End-Netzwerknichtverfügbarkeit und nicht die reine Watchdog-Auslösezeit.

// Vorlage: PDF-Seite 58
== Unterspannungsverhalten <sec-6-7>

// VORLAGE PDF S. 58: Absatz endet unvollständig mit Systemzustand,
Der ergänzende P3-Test zeigt, dass die Energieversorgung eine eigene Fehlerdomäne bildet und dass verschiedene Komponenten nicht gleichzeitig ausfallen müssen. Beim Nucleo- Aufbau war die verringerte LCD-Helligkeit das erste sichtbare Symptom. Danach fiel die Zeichendarstellung aus, während die Hintergrundbeleuchtung noch aktiv blieb; erst bei weiter abgesenkter Eingangsspannung erlosch das LCD vollständig und der STM32 stellte schließlich den Betrieb ein. Dieses Verhalten entspricht einem degradierten Systemzustand, Der Raspberry-Pi-Wert 0x50005 ergänzt die rein visuelle Beobachtung um einen softwareseitigen Statusnachweis. Die gesetzten aktuellen und gespeicherten Bits zeigen, dass Unterspannung und Drosselung nicht nur früher aufgetreten waren, sondern zum Abfragezeitpunkt aktiv waren \[#quelle(<lit-25>), Abschn. “get\_throttled”\].

Die Arbeiten Mementos und DINO verdeutlichen darüber hinaus, dass eine robuste Behandlung wiederkehrender Versorgungsausfälle nicht beim Reset endet: Je nach Persistenzmodell müssen Fortschritt und konsistente Zustandsgrenzen ausdrücklich abgesichert werden \[#quelle(<lit-27>), S. 159–163; #quelle(<lit-28>), S. 575–579\]. Für die vorliegende Arbeit ist daraus vor allem abzuleiten, dass ein zukünftiger Power-Monitor vor Eintritt des unsicheren Bereichs einen definierten Zustand herstellen und dessen Erfolg nach dem Neustart verifizieren sollte.

// Vorlage: PDF-Seite 59
== Validität und Messunsicherheit <sec-6-8>

// Vorlage: PDF-Seite 59
=== Interne Validität <sec-6-8-1>

Automatisierte Tests verwendeten monotone Zeitmessung und Journal-Cursor, um alte Ereignisse auszuschließen. Bei manuellen Leitungsfehlern beginnt die Messung nach Bedienerbestätigung.

// Vorlage: PDF-Seite 59
=== Konstruktvalidität <sec-6-8-2>

Die funktionale Recovery wurde nicht nur über active/running festgestellt. Ein GPS- Dienst musste einen neuen Fix liefern, der UART-Dienst musste PONG und OK erreichen, und der STM32 musste in APP\_RUNTIME zurückkehren. Diese Endpunkte bilden die Nutzfunktion besser ab als reine Prozesszustände.

// Vorlage: PDF-Seite 59
=== Externe Validität <sec-6-8-3>

// VORLAGE PDF S. 59: Satz bricht nach in dieser Arbeit ab.
Die Hardware, das Betriebssystem und die Netzwerktopologie entsprechen dem in dieser Arbeit Andere SD-Karten, Kernelversionen, GPS-Empfangsbedingungen oder Wetterdienste können andere Zeiten erzeugen.

// Vorlage: PDF-Seite 60
== Gesamtbewertung <sec-6-9>

Das Gesamtkonzept erfüllt die Zielsetzung für den in dieser Arbeit untersuchten Aufbau. Es trennt Fehlerdomänen, macht Zustände beobachtbar und eskaliert die Recovery nach Kritikalität. Keine einzelne Ebene könnte alle Fehler abdecken: systemd kann einen Kernel- Hänger nicht beheben, der IWDG keinen Internetausfall und ein Hardware-Reboot wäre für einen Prüfsummenfehler unverhältnismäßig. Die wichtigste Entwurfserkenntnis lautet daher: Ein robustes heterogenes System benötigt nicht den größtmöglichen Reset, sondern die kleinste hinreichende Recovery-Maßnahme plus eine unabhängige Eskalationsstufe für den Fall, dass diese Maßnahme selbst nicht mehr ausgeführt werden kann.
