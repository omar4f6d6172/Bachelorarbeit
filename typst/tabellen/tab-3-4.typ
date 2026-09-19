#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 3.4: Aufgabenteilung zwischen Raspberry Pi und STM32", (1fr, 4fr),
  ([Plattform], [Aufgaben],),
  (
    [Raspberry Pi], [GPS-Verarbeitung, Wetterabfrage, Zustandsablage, Dienstverwaltung, systemd-Watchdogs, UART-Master und Hardware-Watchdog des Systems],
    [STM32], [UART-Protokollvalidierung, LCD-Ansteuerung, Bootdiagnose, Supervisor, lokale Peripherie-Recovery und IWDG-Reset der Firmware],
  ),
)
