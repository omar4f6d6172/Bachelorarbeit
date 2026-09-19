#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 5.2: Übersicht der untersuchten Testfälle (Teil 1)", (0.3fr, 1.15fr, 1.45fr, 1.5fr, 1.4fr),
  ([ID], [Fehlerzustand], [Fehlerinjektion], [Erwartetes Verhalten], [Erfolgskriterium],),
  (
    [N2], [Ausfall der HTTPS-Wetterabfrage], [Blockieren ausgehender TCP-Verbindungen zu Port 443 mit nftables], [INTERNET\_ERROR, Übertragung von NET=ERR, automatische Rückkehr zu NET=OK], [Fehler und Recovery ohne Dienstneustart],
    [G1], [Verlust des GPS-Empfängers], [Entfernen und erneutes Einstecken des USB-GPS], [have\_fix=false, Fallback MODE=LAST, anschließend MODE=LIVE], [Automatische funktionale Wiederherstellung ohne Dienstneustart],
    [C1], [Unterbrechung Raspberry Pi–STM32], [Trennen der TX-Leitung des Raspberry Pi zum RX-Eingang des STM32], [Verbindungsfehler, danach erneut PONG und Daten-ACK], [UART-Datenpfad ohne manuellen Prozessneustart wieder funktionsfähig],
    [H1], [Hänger der STM32-Firmware], [Senden des Befehls HANG], [IWDG-Reset, Bootdiagnose und Rückkehr in APP\_RUNTIME], [Reset-Ursache IWDG und erneutes PING/PONG bestätigt],
    [S1], [Hänger des GPS-Dienstes], [Senden von SIGSTOP an den Prozess], [systemd-Watchdog-Timeout, Prozessabbruch und Neustart], [Neuer PID, Ergebnis watchdog und neuer GPS-Fix],
    [S2], [Absturz des GPS-Dienstes], [Senden von SIGKILL an den Prozess], [Sofortige Fehlererkennung und Neustart nach RestartSec], [Neuer PID, Signalfehler und neuer GPS-Fix],
  ),
)
