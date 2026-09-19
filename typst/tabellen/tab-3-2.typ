#import "../layout.typ": echtetabelle

#echtetabelle("Tabelle 3.2: Nichtfunktionale Anforderungen", (0.6fr, 4fr),
  ([ID], [Anforderung],),
  (
    [NFA-01], [Ein Fehler einer Teilfunktion darf andere funktionsfähige Teilfunktionen nicht unnötig stoppen.],
    [NFA-02], [Die Recovery muss ohne manuellen Eingriff erfolgen, sofern die Fehlerursache nicht physisch bestehen bleibt.],
    [NFA-03], [Nicht kritische Fehler sollen lokal behandelt werden, bevor ein Reset eskaliert wird.],
    [NFA-04], [UART-Datenrahmen müssen gegen ungültige Prüfsummen und Pufferüberläufe abgesichert werden.],
    [NFA-05], [Hängende Prozesse müssen von abgestürzten Prozessen unterschieden und erkannt werden.],
    [NFA-06], [Mess- und Diagnoseinformationen müssen reproduzierbar protokolliert werden.],
    [NFA-07], [Die Watchdog-Aktualisierung darf nicht erfolgen, wenn die überwachte Funktion keinen Fortschritt mehr macht.],
  ),
)
