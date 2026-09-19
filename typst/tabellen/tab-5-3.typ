#import "../layout.typ": echtetabelle

// Hochformat: Szenario und Messgröße gemeinsam, Min/Max als Intervall.
#echtetabelle("Zusammenfassung der zentralen Messergebnisse", key: <tab-5-3>,
  (12mm, 1fr, 13mm, 16mm, 17mm, 26mm),
  ([ID], [Szenario und Hauptmessgröße], [Läufe], [Erfolg], [Mittel [s]], [Min–Max [s]],),
  (
    [N2-F], [*HTTPS-Verbindung blockiert*\
      Fehlerweitergabe bis NET=ERR], [5], [100 %], [7,36], [5,10–8,07],
    [N2-R], [*HTTPS-Verbindung wiederhergestellt*\
      Funktionale Recovery bis NET=OK], [5], [100 %], [10,10], [9,95–10,32],
    [G1-F], [*USB-GPS getrennt*\
      GPS-Fehlerweitergabe bis MODE=LAST], [5], [100 %], [3,12], [0,04–10,85],
    [G1-R], [*USB-GPS verbunden*\
      Recovery bis MODE=LIVE], [5], [100 %], [6,42], [0,04–12,56],
    [C1-F], [*Pi–STM32-Verbindung getrennt*\
      Bedienerbestätigung bis Fehler], [5], [100 %], [3,80], [2,26–5,02],
    [C1-R], [*UART-Verbindung wiederhergestellt*\
      Funktionale Recovery bis ACK], [5], [100 %], [4,73], [0,13–13,30],
    [H1], [*STM32-Firmware-Hänger*\
      HANG bis APP\_RUNTIME], [5], [100 %], [5,70], [5,70–5,70],
    [S1], [*GPS-Dienst hängt*\
      Funktionale Recovery], [5], [100 %], [28,46], [27,51–31,62],
    [S2], [*GPS-Dienst stürzt ab*\
      Funktionale Recovery], [5], [100 %], [5,76], [5,62–6,10],
    [S3], [*UART-Dienst hängt*\
      Funktionale Recovery], [5], [100 %], [33,34], [33,07–33,91],
    [U1], [*Ungültige XOR-Prüfsumme*\
      Ablehnung des ungültigen Rahmens], [5], [100 %], [0,010], [0,010–0,011],
    [U2], [*UART-Pufferüberlauf*\
      Erkennung des Überlaufs], [5], [100 %], [0,018], [0,018–0,019],
    [L1-F], [*LCD-SDA getrennt*\
      Bestätigung bis LCD\_DRIVER=FAIL], [5], [100 %], [0,046], [0,042–0,048],
    [L1-R], [*LCD-SDA verbunden*\
      Bestätigung bis LCD\_DRIVER=OK], [5], [100 %], [0,044], [0,042–0,045],
    [P1], [*Vollständiger Spannungsverlust*\
      Externe Netzwerknichtverfügbarkeit], [3], [100 %], [32,33], [32,00–33,00],
    [P2], [*Linux-Kernel-Hänger*\
      Einzelmessung der externen Netzwerknichtverfügbarkeit: 35,00 s (Durchlauf 02)], [2], [100 %], [–], [–],
  ),
)
