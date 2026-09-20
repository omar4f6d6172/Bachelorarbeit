#import "../layout.typ": echtetabelle

#echtetabelle("Stufen des Ende-zu-Ende-Datenpfads und ihre Verantwortungsgrenzen", key: <tab-3-4>, (0.7fr, 1.4fr, 2.3fr, 2.6fr),
  ([Stufe], [Baustein], [Beitrag zum Gesamtsystem], [Überwachung und zuständige Recovery-Ebene],),
  (
    [1: GPS], [weather-gps.service], [NMEA-Daten des GPS-Empfängers → Positionszustand in gps.json], [Fehlende oder veraltete Position kennzeichnen; Dienst isoliert neu starten],
    [2: Wetterabruf], [weather-net.service], [Positionszustand; Netzwerkpfad als Transport; Wetterdienstantwort → Wetterzustand in weather.json], [Abruffehler als degradierten Zustand weitergeben; Prototyp unterscheidet Netzwerk- und Dienstursache noch nicht; Prozessfehler durch isolierten Dienstneustart behandeln],
    [3: UART], [weather-uart.service und UART], [Positions- und Wetterzustand → serieller Datenrahmen; PING/PONG als Rückmeldepfad], [Fehlende Antwort über PING/PONG erkennen; Übertragung im nächsten Zyklus erneut versuchen; Dienst bei Prozessfehler isoliert neu starten],
    [4: LCD], [STM32-Firmware], [Rahmen validieren → LCD aktualisieren; Verarbeitung mit OK, ERR oder PONG rückmelden], [Fehlerhaften Rahmen verwerfen; LCD lokal reinitialisieren; bei kritischem Firmware-Stillstand IWDG-Reset],
  ),
)
