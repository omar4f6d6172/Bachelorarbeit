#import "../layout.typ": echtetabelle

#echtetabelle("Übersicht der untersuchten Testfälle", key: <tab-5-2>, (0.3fr, 1.15fr, 1.45fr, 1.5fr, 1.4fr),
  ([ID], [Fehlerzustand], [Fehlerinjektion], [Erwartetes Verhalten], [Erfolgskriterium],),
  (
    [N2], [Blockierter HTTPS-Wetterdatenpfad], [Blockieren ausgehender TCP-Verbindungen zu Port 443 mit nftables], [Sammelstatus INTERNET\_ERROR und NET=ERR; automatische Rückkehr zu NET=OK], [Fehlerweitergabe und Recovery ohne Dienstneustart; keine Ursachendifferenzierung],
    [G1], [Verlust des GPS-Empfängers], [Entfernen und erneutes Einstecken des USB-GPS], [have\_fix=false, Fallback MODE=LAST, anschließend MODE=LIVE], [Automatische funktionale Wiederherstellung ohne Dienstneustart],
    [C1], [Unterbrechung Raspberry Pi–STM32], [Trennen der TX-Leitung des Raspberry Pi zum RX-Eingang des STM32], [Verbindungsfehler, danach erneut PONG und Daten-ACK], [UART-Datenpfad ohne manuellen Prozessneustart wieder funktionsfähig],
    [H1], [Hänger der STM32-Firmware], [Senden des Befehls HANG], [IWDG-Reset, Bootdiagnose und Rückkehr in APP\_RUNTIME], [Reset-Ursache IWDG und erneutes PING/PONG bestätigt],
    [S1], [Hänger des GPS-Dienstes], [Senden von SIGSTOP an den Prozess], [systemd-Watchdog-Timeout, Prozessabbruch und Neustart], [Neuer PID, Ergebnis watchdog und neuer GPS-Fix],
    [S2], [Absturz des GPS-Dienstes], [Senden von SIGKILL an den Prozess], [Sofortige Fehlererkennung und Neustart nach RestartSec], [Neuer PID, Signalfehler und neuer GPS-Fix],
    [S3], [Hänger des UART-Dienstes], [Senden von SIGSTOP an den Prozess], [systemd-Watchdog-Neustart, PONG, Daten-ACK und RPI\_LINK\_RECOVERED], [Vollständiger UART-Datenpfad wiederhergestellt],
    [U1], [Ungültige UART-Prüfsumme], [Senden eines Datenrahmens mit absichtlich falscher XOR-Prüfsumme], [Antwort ERR:CHECKSUM, danach Annahme eines gültigen Rahmens], [Fehlerhafte Nachricht verworfen, UART bleibt funktionsfähig],
    [U2], [UART-Pufferlimit], [Senden einer Nachricht mit 140 Zeichen], [Antwort ERR:BUFFER, danach PONG und Annahme eines gültigen Rahmens], [Keine dauerhafte Desynchronisation oder Blockade],
    [L1], [Ausfall der LCD-/I2C-Verbindung], [Trennen und Wiederverbinden der SDA-Leitung], [LCD\_DRIVER=FAIL, Modus DEGRADED, danach lokale Recovery], [Rückkehr zu LCD\_DRIVER=OK und NORMAL ohne Reset],
    [P1], [Vollständiger Spannungsverlust], [Abruptes Trennen und Wiederherstellen der Versorgung], [Automatischer Boot beider Systeme und Start aller Dienste], [GPS, Wetter und STM32-Kommunikation ohne manuellen Eingriff verfügbar],
    [P2], [Linux-Kernel-Hänger], [Kernel-Panic über Magic SysRq bei kernel.panic=0], [Neustart durch BCM2835-Hardware-Watchdog], [Geänderte Boot-ID und vollständige Systemfunktion ohne Power-Cycle],
  ),
)
