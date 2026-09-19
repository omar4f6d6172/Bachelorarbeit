// Kompilieren aus dem Projektordner:
// typst compile typst/bachelorarbeit.typ output/pdf/bachelorarbeit-typst.pdf
#set document(
  title: "Untersuchung von Watchdog- und Recovery-Strategien für ein robustes eingebettetes System",
  author: "Omar Altanbakji",
  date: none,
)
#set text(font: "New Computer Modern", size: 12pt, lang: "de")
#set page(paper: "a4", margin: (left: 27mm, right: 23mm, top: 24mm, bottom: 23mm))
#set par(justify: true, leading: 0.55em, spacing: 0.75em)
#set heading(numbering: none)
#set figure(gap: 0.8em)
#show figure.caption: set text(size: 10pt)
#show figure.where(kind: "table"): set figure.caption(position: top)
#show heading: set text(font: "Noto Sans", weight: "bold")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(10mm)
  block(above: 0pt, below: 8mm, text(size: 20pt, context {
    if it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      h(0.35em)
    }
    it.body
  }))
}
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 11.5pt)
#show raw: set text(font: "DejaVu Sans Mono", size: 8.3pt)
#show raw.where(block: true): it => block(
  breakable: false, width: 100%, inset: 9pt, fill: luma(97%), stroke: 0.3pt + luma(83%),
  radius: 2pt, above: 1em, below: 1em, it,
)

// Titelblatt
#align(center)[
  #v(12mm)
  #text(size: 23pt)[HTW Berlin]
  #v(6mm)
  #text(size: 15pt)[Hochschule für Technik und Wirtschaft Berlin]
  #v(5mm)
  #text(size: 15pt)[Studiengang Computer Engineering]
  #v(30mm)
  #text(size: 21pt)[Bachelorarbeit]
  #v(18mm)
  #text(font: "Noto Sans", size: 22pt, weight: "bold", hyphenate: false)[
    Untersuchung von Watchdog- und\
    Recovery-Strategien\
    für ein robustes eingebettetes System
  ]
  #v(25mm)
  #set text(size: 11pt)
  #table(columns: (33mm, auto), stroke: none, align: left, inset: (x: 4pt, y: 4pt),
    [Verfasser:], [Omar Altanbakji],
    [Matrikelnummer:], [S0587682],
    [Studiengang:], [Computer Engineering],
    [Erstgutachter:], [Prof. Dr. Jochen Kerdels],
    [Zweitgutachter:], [Prof. Dr. Marcin Brzozowski],
    [Abgabedatum:], [21. September 2026],
  )
]
#pagebreak()
#set page(numbering: "I", number-align: center)
#counter(page).update(1)
#include "kapitel/00.typ"
#include "abkuerzungen.typ"
#pagebreak()
#outline(title: [Inhaltsverzeichnis], indent: 1.1em, depth: 3)
#pagebreak()
#outline(title: [Abbildungsverzeichnis], target: figure.where(kind: "image"))
#pagebreak()
#outline(title: [Tabellenverzeichnis], target: figure.where(kind: "table"))
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
#set heading(numbering: "1.1.")
#counter(heading).update(0)
#include "kapitel/01.typ"
#include "kapitel/02.typ"
#include "kapitel/03.typ"
#include "kapitel/04.typ"
#include "kapitel/05.typ"
#include "kapitel/06.typ"
#include "kapitel/07.typ"
#include "literatur.typ"
