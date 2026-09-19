#import "../layout.typ": echtetabelle

#set page(paper: "a4", flipped: true, margin: (x: 18mm, y: 20mm))
#echtetabelle("Tabelle 5.3: Zusammenfassung der zentralen Messergebnisse", (0.6fr, 2.3fr, 0.55fr, 0.65fr, 3fr, 0.8fr, 0.7fr, 0.7fr),
  ([ID], [Szenario], [Läufe], [Erfolg], [Hauptmessgröße], [Mittel \[s\]], [Min \[s\]], [Max \[s\]],),
  (
    [N2-F], [HTTPS-Verbindung blockiert], [5], [100 %], [Fehlerweitergabe bis NET=ERR], [7,36], [5,10], [8,07],
    [N2-R], [HTTPS-Verbindung wiederhergestellt], [5], [100 %], [Funktionale Recovery bis NET=OK], [10,10], [9,95], [10,32],
    [G1-F], [USB-GPS getrennt], [5], [100 %], [GPS-Fehlerweitergabe bis MODE=LAST], [3,12], [0,04], [10,85],
    [G1-R], [USB-GPS verbunden], [5], [100 %], [Recovery bis MODE=LIVE], [6,42], [0,04], [12,56],
    [C1-F], [Pi–STM32-Verbindung getrennt], [5], [100 %], [Bedienerbestätigung bis Fehler], [3,80], [2,26], [5,02],
    [C1-R], [UART-Verbindung wiederhergestellt], [5], [100 %], [Funktionale Recovery bis ACK], [4,73], [0,13], [13,30],
    [H1], [STM32-Firmware-Hänger], [5], [100 %], [HANG bis APP\_RUNTIME], [5,70], [5,70], [5,70],
    [S1], [GPS-Dienst hängt], [5], [100 %], [Funktionale Recovery], [28,46], [27,51], [31,62],
    [S2], [GPS-Dienst stürzt ab], [5], [100 %], [Funktionale Recovery], [5,76], [5,62], [6,10],
    [S3], [UART-Dienst hängt], [5], [100 %], [Funktionale Recovery], [33,34], [33,07], [33,91],
    [U1], [Ungültige XOR-Prüfsumme], [5], [100 %], [Ablehnung des ungültigen Rahmens], [0,010], [0,010], [0,011],
    [U2], [UART-Pufferüberlauf], [5], [100 %], [Erkennung des Überlaufs], [0,018], [0,018], [0,019],
    [L1-F], [LCD-SDA getrennt], [5], [100 %], [Bestätigung bis LCD\_DRIVER=FAIL], [0,046], [0,042], [0,048],
    [L1-R], [LCD-SDA verbunden], [5], [100 %], [Bestätigung bis LCD\_DRIVER=OK], [0,044], [0,042], [0,045],
    [P1], [Vollständiger Spannungsverlust], [3], [100 %], [Externe Netzwerknichtverfügbarkeit], [32,33], [32,00], [33,00],
    [P2], [Linux-Kernel-Hänger], [2], [100 %], [Einzelmessung der externen Netzwerknichtverfügbarkeit: 35,00 s (Durchlauf 02)], [–], [–], [–],
  ),
)
