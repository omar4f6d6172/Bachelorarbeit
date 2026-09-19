#import "../layout.typ": echtetabelle

#echtetabelle("Aufgabenteilung zwischen Raspberry Pi und STM32", key: <tab-3-4>, (1fr, 4fr),
  ([Plattform], [Aufgaben],),
  (
    [Raspberry Pi], [GPS-Verarbeitung, Wetterabfrage, Zustandsablage, Dienstverwaltung, systemd-Watchdogs, UART-Master und Hardware-Watchdog des Systems],
    [STM32], [UART-Protokollvalidierung, LCD-Ansteuerung, Bootdiagnose, Supervisor, lokale Peripherie-Recovery und IWDG-Reset der Firmware],
  ),
)
