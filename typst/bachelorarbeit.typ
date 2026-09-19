// Kompilieren aus dem Projektordner:
// typst compile typst/bachelorarbeit.typ output/pdf/bachelorarbeit-typst.pdf
#set document(
  title: "Untersuchung von Watchdog- und Recovery-Strategien für ein robustes eingebettetes System",
  author: "Omar Altanbakji",
  date: none,
)
// Klassischer, einseitiger Satz für die digitale PDF-Abgabe.
#set text(font: "Libertinus Serif", size: 11.5pt, lang: "de", region: "DE")
#set page(paper: "a4", margin: (x: 25mm, top: 25mm, bottom: 24mm))
#set par(justify: true, leading: 0.65em, spacing: 0.65em)
#set heading(numbering: none)
#set figure(gap: 7pt)
#show figure: set block(above: 1em, below: 1em)
#show figure.caption: set text(size: 10pt)
#show figure.caption: set par(justify: false, leading: 0.4em)
#show figure.where(kind: "table"): set figure.caption(position: top)
#show heading: set text(weight: "bold", hyphenate: false)
#show heading.where(level: 1): set text(size: 19pt)
#show heading.where(level: 1): set block(above: 0pt, below: 9mm)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  if it.numbering != none {
    counter(figure.where(kind: "image")).update(0)
    counter(figure.where(kind: "table")).update(0)
    counter(math.equation).update(0)
  }
  v(6mm)
  it
}
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 2): set block(above: 1.5em, below: 0.75em)
#show heading.where(level: 3): set text(size: 12pt)
#show heading.where(level: 3): set block(above: 1.2em, below: 0.6em)
#set raw(theme: none)
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt)
#show raw.where(block: true): it => block(
  breakable: false, width: 100%, inset: 9pt, fill: luma(97%),
  stroke: (left: 0.6pt + luma(55%)), above: 1em, below: 1em, it,
)

// Titelblatt ohne Seitenzahl und Kopfzeile.
#align(center)[
  #set par(justify: false, leading: 0.65em)
  #v(10mm)
  #text(size: 17pt, weight: "bold")[Hochschule für Technik und Wirtschaft Berlin]
  #v(4mm)
  #text(size: 12pt)[Studiengang Computer Engineering]
  #v(30mm)
  #text(size: 17pt)[Bachelorarbeit]
  #v(13mm)
  #text(size: 23pt, weight: "bold", hyphenate: false)[
    Untersuchung von Watchdog- und Recovery-Strategien
    für ein robustes eingebettetes System
  ]
  #v(15mm)
  #text(size: 12pt)[vorgelegt von]
  #v(3mm)
  #text(size: 15pt, weight: "bold")[Omar Altanbakji]
  #v(1fr)
  #set text(size: 11pt)
  #table(columns: (34mm, 85mm), stroke: none, align: left, inset: (x: 0pt, y: 4pt),
    [Matrikelnummer], [S0587682],
    [Erstgutachter], [Prof. Dr. Jochen Kerdels],
    [Zweitgutachter], [Prof. Dr. Marcin Brzozowski],
    [Abgabedatum], [21. September 2026],
  )
  #v(12mm)
]
#pagebreak()
#set page(numbering: "I", number-align: center)
#counter(page).update(1)
#include "kapitel/00.typ"
#pagebreak()
#[
  #set text(size: 10.5pt)
  #set par(leading: 0.45em)
  #show outline.entry: set block(above: 0.42em, below: 0.42em)
  #show outline.entry.where(level: 1): set text(weight: "bold")
  #outline(title: [Inhaltsverzeichnis], indent: 1.2em, depth: 3)
]
#pagebreak()
#heading(numbering: none)[Abbildungsverzeichnis]
#outline(title: none, target: figure.where(kind: "image"))
#pagebreak()
#heading(numbering: none)[Tabellenverzeichnis]
#outline(title: none, target: figure.where(kind: "table"))
#include "abkuerzungen.typ"
#pagebreak()
#set page(numbering: "1", header: context {
  let kapitel = query(heading.where(level: 1)).filter(h => h.location().page() <= here().page())
  if kapitel.len() > 0 {
    set text(size: 9pt)
    let aktuell = kapitel.last()
    if aktuell.numbering != none {
      numbering(aktuell.numbering, ..counter(heading).at(aktuell.location()))
      h(0.4em)
    }
    aktuell.body
    v(2pt)
    line(length: 100%, stroke: 0.35pt + luma(60%))
  }
})
#counter(page).update(1)
#set heading(numbering: "1.1")
#counter(heading).update(0)
#include "kapitel/01.typ"
#include "kapitel/02.typ"
#include "kapitel/03.typ"
#include "kapitel/04.typ"
#include "kapitel/05.typ"
#include "kapitel/06.typ"
#[
  #set par(leading: 0.6em, spacing: 0.55em)
  #include "kapitel/07.typ"
]
#include "literatur.typ"
