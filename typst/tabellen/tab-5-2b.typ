#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 5.2: Übersicht der untersuchten Testfälle (Teil 2)", (0.3fr, 1.15fr, 1.45fr, 1.5fr, 1.4fr),
  ([ID], [Fehlerzustand], [Fehlerinjektion], [Erwartetes Verhalten], [Erfolgskriterium],),
  (
    [S3], [Hänger des UART-Dienstes], [Senden von SIGSTOP an den Prozess], [systemd-Watchdog-Neustart, PONG, Daten-ACK und RPI\_LINK\_RECOVERED], [Vollständiger UART-Datenpfad wiederhergestellt],
    [U1], [Ungültige UART-Prüfsumme], [Senden eines Datenrahmens mit absichtlich falscher XOR-Prüfsumme], [Antwort ERR:CHECKSUM, danach Annahme eines gültigen Rahmens], [Fehlerhafte Nachricht verworfen, UART bleibt funktionsfähig],
    [U2], [UART-Pufferlimit], [Senden einer Nachricht mit 140 Zeichen], [Antwort ERR:BUFFER, danach PONG und Annahme eines gültigen Rahmens], [Keine dauerhafte Desynchronisation oder Blockade],
    [L1], [Ausfall der LCD-/I2C-Verbindung], [Trennen und Wiederverbinden der SDA-Leitung], [LCD\_DRIVER=FAIL, Modus DEGRADED, danach lokale Recovery], [Rückkehr zu LCD\_DRIVER=OK und NORMAL ohne Reset],
    [P1], [Vollständiger Spannungsverlust], [Abruptes Trennen und Wiederherstellen der Versorgung], [Automatischer Boot beider Systeme und Start aller Dienste], [GPS, Wetter und STM32-Kommunikation ohne manuellen Eingriff verfügbar],
    [P2], [Linux-Kernel-Hänger], [Kernel-Panic über Magic SysRq bei kernel.panic=0], [Neustart durch BCM2835-Hardware-Watchdog], [Geänderte Boot-ID und vollständige Systemfunktion ohne Power-Cycle],
  ),
)
