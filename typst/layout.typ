// Gemeinsame Satzbausteine ohne externe Pakete.
#import "diagramme.typ": diagramme

#let vorlage(datei, beschriftung) = context {
  let kapitel = counter(heading).get().first()
  let grafik = if datei in diagramme {
    diagramme.at(datei)
  } else {
    // Originalbeleg: ausschließlich die eingebrannte äußere Beschriftung
    // liegt außerhalb dieses Sichtfensters. Explizite Bildhöhe verhindert Skalierung.
    layout(size => block(width: 100%, height: size.width * 286 / 1077, clip: true,
      image("abbildungen/" + datei, width: size.width,
        height: size.width * 363 / 1077, alt: beschriftung),
    ))
  }
  let element = figure(grafik,
    caption: [#beschriftung], kind: "image", supplement: [Abbildung],
    numbering: n => numbering("1.1", kapitel, n),
  )
  [#element#label(datei.replace(".png", ""))]
}

#let echtetabelle(beschriftung, spalten, kopf, zellen, key: none) = context {
  let kapitel = counter(heading).get().first()
  set text(size: 10pt)
  set par(justify: false, leading: 0.4em)
  show figure: set block(breakable: key in (<tab-5-2>, <tab-5-3>))
  let element = figure(
    table(
      columns: spalten, align: left, inset: (x: 5pt, y: 5pt), stroke: none,
      table.header(
        table.hline(stroke: 0.6pt),
        ..kopf.map(x => strong(x)),
        table.hline(stroke: 0.35pt),
      ),
      ..zellen,
      table.hline(stroke: 0.6pt),
    ),
    caption: [#beschriftung], kind: "table", supplement: [Tabelle],
    numbering: n => numbering("1.1", kapitel, n),
  )
  if key != none { [#element#key] } else { element }
}

// Automatische Nummerierung in der bisherigen Reihenfolge; stabile Schlüssel
// verbinden jede Quellenangabe mit ihrem Eintrag, auch nach Umstellungen.
#let literaturzaehler = counter("literatur")
#let lit(key, body) = {
  literaturzaehler.step()
  [#metadata("literature-entry")#key]
  block(breakable: false, above: 0pt, below: 8pt)[
    #set text(size: 10.5pt)
    #set par(justify: false, leading: 0.5em)
    #grid(columns: (9mm, 1fr), context [\[#literaturzaehler.display()\]], body)
  ]
}
#let quelle(key) = context link(key, numbering("1", ..literaturzaehler.at(key)))

#let gleichung(body, key) = context {
  let kapitel = counter(heading).get().first()
  let element = math.equation(body, block: true,
    numbering: n => numbering("(1.1)", kapitel, n))
  [#element#key]
}
