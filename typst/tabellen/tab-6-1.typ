#import "../layout.typ": echtetabelle

#echtetabelle("Zuordnung der untersuchten Fehlerklassen zu Recovery-Ebenen", key: <tab-6-1>, (1.4fr, 1.4fr, 2fr),
  ([Fehlerklasse], [Strategie], [Interpretation in der Arbeit],),
  (
    [Ungültige Prüfsumme / Pufferüberlauf], [Rahmen verwerfen bzw. Empfänger synchronisieren], [Fehler bleibt auf Protokollebene isoliert.],
    [LCD-/I2C-Ausfall], [Lokale Komponenten-Recovery], [Anzeigeausfall stoppt den übrigen Datenpfad nicht.],
    [GPS-Verlust], [Gekennzeichneter Fallback und Retry], [Letzte zulässige Position wird als MODE=LAST gekennzeichnet.],
    [Blockierter HTTPS-Wetterdatenpfad], [Degradierter Zustand und periodischer Retry], [Kein gültiger Wetterdatensatz; Ursache innerhalb des Datenpfads bleibt unbestimmt.],
    [Prozessabsturz], [systemd-Restart], [Prozessende ist unmittelbar sichtbar.],
    [Prozess-Hänger], [systemd-Service-Watchdog], [Fehlender Funktionsfortschritt muss über ausbleibende Keepalives erkannt werden.],
    [STM32-Firmware-Hänger], [IWDG-Reset], [Firmware kann keine lokale Recovery mehr ausführen.],
    [Linux-Kernel-Hänger], [Hardware-Watchdog], [Linux-Prozesse im Benutzerraum und systemd sind nicht mehr handlungsfähig.],
    [Vollständiger Spannungsverlust], [Automatischer Boot und Dienststart], [Recovery beginnt erst nach Rückkehr der Versorgung.],
  ),
)
