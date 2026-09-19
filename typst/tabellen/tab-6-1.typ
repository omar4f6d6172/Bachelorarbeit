#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 6.1: Zuordnung der untersuchten Fehlerklassen zu Recovery-Ebenen", (1.4fr, 1.4fr, 2fr),
  ([Fehlerklasse], [Strategie], [Interpretation in der Arbeit],),
  (
    [Ungültige Prüfsumme / Pufferüberlauf], [Rahmen verwerfen bzw. Empfänger synchronisieren], [Fehler bleibt auf Protokollebene isoliert.],
    [LCD-/I2C-Ausfall], [Lokale Komponenten-Recovery], [Anzeigeausfall stoppt den übrigen Datenpfad nicht.],
    [GPS- oder Netzwerkverlust], [Gekennzeichneter Fallback und Retry], [Noch verfügbare Funktionen bleiben aktiv.],
    [Prozessabsturz], [systemd-Restart], [Prozessende ist unmittelbar sichtbar.],
    [Prozess-Hänger], [systemd-Service-Watchdog], [Liveness muss über ausbleibende Keepalives erkannt werden.],
    [STM32-Firmware-Hänger], [IWDG-Reset], [Firmware kann keine lokale Recovery mehr ausführen.],
    [Linux-Kernel-Hänger], [Hardware-Watchdog], [Userspace und systemd sind nicht mehr handlungsfähig.],
    [Vollständiger Spannungsverlust], [Automatischer Boot und Dienststart], [Recovery beginnt erst nach Rückkehr der Versorgung.],
  ),
)
