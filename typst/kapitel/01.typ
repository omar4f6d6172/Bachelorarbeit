#import "../layout.typ": *

// Vorlage: PDF-Seite 10
= Einleitung <sec-1>

// Vorlage: PDF-Seite 10
== Motivation <sec-1-1>

Eingebettete Systeme übernehmen klar abgegrenzte Funktionen innerhalb technischer Anlagen und arbeiten häufig lange ohne unmittelbare menschliche Überwachung. Ihre Verfügbarkeit hängt nicht allein von der eigentlichen Anwendungslogik ab. Sensoren und Aktoren, Kommunikationspfade, Betriebssystemdienste, externe Server und die Energieversorgung bilden zusätzliche Fehlerdomänen. Eine Implementierung, die nur den Normalfall berücksichtigt, kann bereits durch einen vorübergehenden Netzwerkausfall oder einen blockierten Prozess dauerhaft unbrauchbar werden. Robustheit bedeutet in diesem Zusammenhang nicht, Fehler vollständig zu verhindern. Entscheidend ist, dass Fehler erkannt, eingegrenzt und mit einer zur Fehlerklasse passenden Maßnahme behandelt werden. Die Dependability-Taxonomie unterscheidet unter anderem Verfügbarkeit, Zuverlässigkeit, Integrität und Wartbarkeit als Eigenschaften, die Vertrauen in ein System begründen \[#quelle(<lit-01>), S. 13–14\]. Recovery-orientierte Ansätze verschieben den Entwurfsfokus zusätzlich von der ausschließlichen Vermeidung von Fehlern hin zu einer schnellen und überprüfbaren Wiederherstellung \[#quelle(<lit-02>), S. 1\]. Ein pauschaler Neustart des Gesamtsystems ist zwar einfach, aber nicht für jede Störung angemessen. Ein ungültiger UART-Datenrahmen kann lokal verworfen werden. Ein nicht kritischer Displayausfall kann zu einem degradierten Betrieb führen, ohne die übrige Funktion zu unterbrechen. Ein Firmware-Hänger des Mikrocontrollers erfordert dagegen einen Reset, während ein Kernel-Hänger des Linux-Systems nur durch eine vom betroffenen Softwarepfad unabhängige Instanz behoben werden kann. Ein Watchdog überwacht, ob die zugeordnete Funktion innerhalb einer Frist ein gültiges Fortschrittszeichen liefert. Als Recovery wird in dieser Arbeit die Rückkehr in einen definierten funktionsfähigen Zustand bezeichnet; ein degradierter Betrieb erhält dabei die Kernfunktion mit bewusst eingeschränktem Funktionsumfang. Daraus entsteht die Notwendigkeit einer abgestuften Watchdog- und Recovery-Architektur.

// Vorlage: PDF-Seite 10
== Problemstellung <sec-1-2>

Die zentrale Problemstellung besteht darin, geeignete Überwachungs- und Wiederherstellungsmechanismen für unterschiedliche Fehlerklassen in einem heterogenen eingebetteten System auszuwählen und ihre Wirksamkeit experimentell zu bewerten. Das betrachtete System umfasst einen Raspberry Pi mit Linux, einen STM32-Mikrocontroller, einen Binghe VK-162 USB-GPS-Empfänger, eine Internetverbindung und ein LCD. Fehler können daher auf Daten-, Komponenten-, Prozess-, Firmware- und Systemebene auftreten. Die technische Herausforderung liegt nicht nur im Aktivieren einzelner Watchdogs. Ein Prozessabsturz ist für den Service-Manager unmittelbar sichtbar, während ein weiterhin vorhandener, aber hängender Prozess erst durch ausbleibende Fortschrittsnachweise erkannt wird. Ein Watchdog-Lebenszeichen darf zudem nicht bedingungslos erzeugt werden, weil sonst ein funktionierender Timer einen Stillstand der eigentlichen Nutzfunktion verdecken könnte. Schließlich soll eine Recovery möglichst nur die tatsächlich betroffene Fehlerdomäne zurücksetzen.

// Vorlage: PDF-Seite 11
== Zielsetzung <sec-1-3>

Ziel dieser Arbeit ist die Untersuchung, Implementierung und experimentelle Bewertung mehrerer Watchdog- und Recovery-Strategien für ein heterogenes System aus Raspberry Pi und STM32. Als Testanwendung bestimmt der Raspberry Pi eine Position über GPS, ruft Wetterdaten ab und überträgt den Zustand an den STM32, der die Daten auf einem LCD darstellt. Die Wetteranwendung ist Mittel zum Zweck: Sie erzeugt einen nachvollziehbaren Datenpfad mit realen externen Abhängigkeiten und erlaubt die gezielte Fehlerinjektion, also das kontrollierte Herbeiführen eines zuvor festgelegten Fehlers. Untersucht werden die Auswahl der Recovery-Ebene, die Erkennungs- und Wiederherstellungszeiten sowie die Frage, ob ein vorab durch messbare Kriterien definierter funktionaler Endzustand ohne manuellen Neustart erneut erreicht wird.

// Vorlage: PDF-Seite 11
== Forschungsfragen <sec-1-4>

F1: Wie muss ein heterogenes eingebettetes System strukturiert werden, damit Fehler auf der jeweils geeigneten Ebene erkannt und behandelt werden?

F2: Wie unterscheiden sich lokale Recovery, Dienstneustart, Mikrocontroller-Reset und vollständiger Systemneustart hinsichtlich Eingriffstiefe und funktionaler Wiederherstellungszeit?

F3: Welche Unterschiede zeigen sich zwischen Prozessabsturz, Prozess-Hänger, Firmware-Hänger und vollständigem Linux-Hänger?

F4: In welchem Umfang kann das entwickelte System nach den betrachteten Hardware-, Kommunikations- und Softwarefehlern automatisch in einen definierten Zustand zurückkehren?

// Vorlage: PDF-Seite 12
== Aufbau der Arbeit <sec-1-5>

#ref(<sec-2>, supplement: [Kapitel]) führt Dependability, Watchdogs, Supervisoren und Recovery-Strategien ein. #ref(<sec-3>, supplement: [Kapitel]) verbindet Anforderungen und Fehlermodell unmittelbar mit dem Systementwurf und der komponentenorientierten Implementierung auf Raspberry Pi und STM32. #ref(<sec-5>, supplement: [Kapitel]) dokumentiert Fehlerinjektion, Messmethodik und Ergebnisse. #ref(<sec-6>, supplement: [Kapitel]) ordnet die Ergebnisse ein und beantwortet die Forschungsfragen. #ref(<sec-7>, supplement: [Kapitel]) fasst die Erkenntnisse zusammen und nennt Erweiterungsmöglichkeiten.
