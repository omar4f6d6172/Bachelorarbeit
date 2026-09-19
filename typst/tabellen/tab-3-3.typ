#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 3.3: Fehlermodell und vorgesehene Recovery-Strategien", (1.3fr, 1fr, 1.5fr, 2fr),
  ([Fehler], [Ebene], [Erkennung], [Recovery],),
  (
    [Ungültige UART-Prüfsumme], [Daten], [Prüfsummenvergleich], [Rahmen verwerfen, Fehlerantwort senden],
    [UART-Pufferüberlauf], [Daten/Link], [Längenbegrenzung], [Pufferzustand verwerfen und Synchronisation fortsetzen],
    [HTTPS-Verbindung unterbrochen], [Netzwerk], [Ausnahme bei Wetterabfrage], [Fehlerzustand speichern und periodisch erneut versuchen],
    [Kein GPS-Gerät oder kein Fix], [Peripherie], [Geräte-/Timeout-Prüfung], [Letzte gültige Daten verwenden, MODE=LAST],
    [UART-Verbindung unterbrochen], [UART-Verbindung], [PING/PONG-Timeout], [Wiederholungsversuch und automatische Wiederherstellung der Verbindung],
    [LCD getrennt], [I2C/LCD], [NACK oder Schreibfehler], [Lokale LCD-/I2C-Recovery, Modus DEGRADED],
    [Linux-Dienst abgestürzt], [Prozess], [Prozessende durch systemd], [Automatischer Dienstneustart],
    [Linux-Dienst hängt], [Prozess], [Ausbleibendes systemd-Watchdog-Signal], [Prozess beenden und Dienst neu starten],
    [STM32-Firmware hängt], [Firmware], [IWDG-Timeout], [Mikrocontroller-Reset und Bootdiagnose],
    [Linux-Kernel hängt], [Linux], [BCM2835-Hardware-Watchdog], [Vollständiger Neustart des Raspberry Pi],
    [Versorgung fällt aus], [System], [Neustart nach Rückkehr der Versorgung], [Automatischer Boot und Start aller Dienste],
  ),
)
