#import "../layout.typ": echtetabelle

#echtetabelle("Funktionale Anforderungen", key: <tab-3-1>, (0.6fr, 4fr),
  ([ID], [Anforderung],),
  (
    [FA-01], [Das System muss eine gültige GPS-Position erfassen können.],
    [FA-02], [Das System muss Wetterdaten für die zuletzt gültige Position abrufen.],
    [FA-03], [Der Raspberry Pi muss den GPS-Zustand und die Verfügbarkeit eines gültigen Wetterdatensatzes an den STM32 übertragen.],
    [FA-04], [Der STM32 muss gültige Datenrahmen prüfen und auf dem LCD darstellen.],
    [FA-05], [Der Raspberry Pi und der STM32 müssen ihre Verbindung über einen Heartbeat prüfen.],
    [FA-06], [Fehlerzustände müssen intern protokolliert und gegenüber nachgelagerten Komponenten gekennzeichnet werden.],
    [FA-07], [Nach Wegfall einer Störung muss der Normalbetrieb automatisch wiederhergestellt werden.],
  ),
)
