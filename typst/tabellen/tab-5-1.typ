#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 5.1: Hardwarekomponenten des Versuchsaufbaus", (1.6fr, 3fr),
  ([Komponente], [Funktion],),
  (
    [Raspberry Pi 4 Model B], [Positionsverarbeitung, Wetterabfrage, Dienstverwaltung, Fehlerbehandlung und Kommunikation mit dem STM32],
    [STM32 Nucleo L432KC], [Displaysteuerung, Kommunikationsvalidierung, Bootdiagnose, Supervisor und hardwarebasierte Watchdog-Recovery],
    [Binghe VK-162 USB-GPS-Empfänger], [Bestimmung der geografischen Position über NMEA-Datensätze],
    [LCD2004 mit AZDelivery-I2C-Adapter (PCF8574)], [Anzeige von Wetterdaten und aktuellem Systemzustand],
    [UART-Verbindung], [Bidirektionale Kommunikation zwischen Raspberry Pi und STM32],
    [I2C-Verbindung], [Kommunikation zwischen STM32 und LCD-Modul],
  ),
)
