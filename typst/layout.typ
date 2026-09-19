// Gemeinsame Bausteine; keine externen Typst-Pakete erforderlich.
#let vorlage(datei, beschriftung, art: "image") = {
  // Die Originalgrafik enthält bereits ihre Beschriftung. Die semantische
  // Beschriftung bleibt für das automatisch erzeugte Verzeichnis verfügbar.
  show figure.caption: none
  figure(
    image("abbildungen/" + datei, width: 100%),
    caption: [#beschriftung],
    kind: art,
    supplement: none,
    numbering: none,
  )
}

#let echtetabelle(beschriftung, spalten, kopf, zellen) = {
  set text(size: 10pt)
  set par(justify: false, leading: 0.45em)
  show figure.caption: set text(size: 10pt)
  figure(
    table(
      columns: spalten,
      align: left,
      inset: (x: 5pt, y: 5pt),
      stroke: none,
      table.hline(stroke: 0.6pt),
      table.header(..kopf.map(x => strong(x))),
      table.hline(stroke: 0.35pt),
      ..zellen,
      table.hline(stroke: 0.6pt),
    ),
    caption: [#beschriftung],
    kind: "table", supplement: none, numbering: none,
  )
}

#let lit(nummer, body) = block(breakable: false, above: 0pt, below: 5pt)[
  #set text(size: 11pt)
  #set par(justify: false, leading: 0.5em)
  #grid(columns: (9mm, 1fr), text("[" + str(nummer) + "]"), body)
]
