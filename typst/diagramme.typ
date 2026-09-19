// Native Vektorgrafiken. Koordinaten sind relativ zu einer 160 Einheiten breiten
// Zeichenfläche; Text, Linien und Daten bleiben vollständig in Typst bearbeitbar.
#let flaeche(hoehe, body) = layout(size => {
  let u = size.width / 160
  block(width: size.width, height: hoehe * u, body(u))
})
#let beschriftung(u, x, y, w, h, body, groesse: 3.3, fett: false, hintergrund: none) = place(
  top + left, dx: x*u, dy: y*u,
  block(width: w*u, height: h*u, fill: hintergrund, inset: 0pt)[
    #set text(size: groesse*u, weight: if fett { "bold" } else { "regular" }, hyphenate: false)
    #set par(justify: false, leading: 0.25em)
    #align(center + horizon, body)
  ],
)
#let knoten(u, x, y, w, h, body, fett: false) = {
  place(top + left, dx: x*u, dy: y*u,
    rect(width: w*u, height: h*u, stroke: 0.55pt, fill: luma(97%)))
  beschriftung(u, x+1, y+1, w - 2, h - 2, body, fett: fett)
}
#let linie(u, a, b, gestrichelt: false, farbe: black) = place(
  top + left, dx: a.at(0)*u, dy: a.at(1)*u,
  line(end: ((b.at(0) - a.at(0))*u, (b.at(1) - a.at(1))*u),
    stroke: (paint: farbe, thickness: 0.55pt, dash: if gestrichelt { "dashed" } else { "solid" })),
)
#let pfeil(u, punkte, gestrichelt: false) = {
  for i in range(punkte.len() - 1) { linie(u, punkte.at(i), punkte.at(i+1), gestrichelt: gestrichelt) }
  let a = punkte.at(punkte.len() - 2)
  let b = punkte.last()
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let laenge = calc.sqrt(dx*dx+dy*dy)
  let vx = dx/laenge
  let vy = dy/laenge
  place(top + left, polygon(
    (b.at(0)*u, b.at(1)*u),
    ((b.at(0) - 2*vx+0.85*vy)*u, (b.at(1) - 2*vy - 0.85*vx)*u),
    ((b.at(0) - 2*vx - 0.85*vy)*u, (b.at(1) - 2*vy+0.85*vx)*u),
    fill: black, stroke: none,
  ))
}
#let marke(u, x, y, body) = beschriftung(u, x, y, 8, 5, body, groesse: 3, hintergrund: white)

#let architektur = flaeche(75, u => {
  // Domänengrenzen
  place(top + left, dx: 1*u, dy: 1*u, rect(width: 79*u, height: 65*u,
    stroke: (thickness: 0.5pt, dash: "dashed")))
  place(top + left, dx: 97*u, dy: 30*u, rect(width: 62*u, height: 36*u,
    stroke: (thickness: 0.5pt, dash: "dashed")))
  knoten(u, 44, 5, 32, 16, [Wetter-API\ HTTPS])
  knoten(u, 5, 39, 30, 21, [Binghe VK-162\ USB-GPS / NMEA])
  knoten(u, 44, 39, 32, 21, [Raspberry Pi\ GPS, Netzwerk, UART])
  knoten(u, 101, 39, 29, 21, [STM32L432KC\ Supervisor\ und IWDG])
  knoten(u, 137, 36, 21, 26, [LCD2004\ AZDelivery\ I2C-Adapter])
  pfeil(u, ((35,49), (44,49)))
  beschriftung(u, 34, 42, 11, 5, [NMEA], groesse: 2.8)
  pfeil(u, ((58,39), (58,21)))
  pfeil(u, ((63,21), (63,39)))
  beschriftung(u, 64, 26, 15, 5, [HTTPS], groesse: 3)
  pfeil(u, ((76,44), (101,44)))
  pfeil(u, ((101,56), (76,56)))
  beschriftung(u, 77, 37, 23, 5, [Status], groesse: 3)
  beschriftung(u, 77, 57, 23, 5, [ACK / PONG], groesse: 2.9)
  pfeil(u, ((130,49), (137,49)))
  beschriftung(u, 130, 42, 9, 5, [I2C], groesse: 2.9)
  beschriftung(u, 1, 67, 79, 7, [Linux- und Netzwerkdomäne], groesse: 3)
  beschriftung(u, 91, 67, 69, 7, [Mikrocontroller- und Peripheriedomäne], groesse: 2.9)
})

#let dienste = flaeche(77, u => {
  knoten(u, 1, 5, 30, 16, [weather-gps\ .service])
  knoten(u, 46, 5, 32, 16, [/dev/shm/weather/\ gps.json])
  knoten(u, 94, 5, 30, 16, [weather-net\ .service])
  knoten(u, 130, 36, 29, 17, [/dev/shm/weather/\ weather.json])
  knoten(u, 47, 48, 37, 17, [weather-uart.service])
  knoten(u, 103, 48, 24, 17, [/dev/serial0\ STM32])
  pfeil(u, ((31,13),(46,13)))
  beschriftung(u, 29, 0, 19, 5, [schreibt], groesse: 2.8)
  pfeil(u, ((78,13),(94,13)), gestrichelt: true)
  beschriftung(u, 78, 6, 16, 5, [liest], groesse: 2.8)
  pfeil(u, ((124,13),(145,13),(145,36)))
  beschriftung(u, 128, 5, 28, 5, [schreibt], groesse: 2.8)
  pfeil(u, ((62,21),(62,48)), gestrichelt: true)
  pfeil(u, ((130,44),(74,44),(74,48)), gestrichelt: true)
  pfeil(u, ((84,57),(103,57)))
  beschriftung(u, 84, 49, 19, 5, [UART], groesse: 3)
  beschriftung(u, 0, 69, 160, 7,
    [Durchgezogen: Schreiben bzw. Übertragen · Gestrichelt: Lesen], groesse: 3)
})

#let eskalation = flaeche(91, u => {
  let stufen = (
    [6. Raspberry Pi durch Hardware-Watchdog neu starten],
    [5. STM32 durch IWDG zurücksetzen],
    [4. Einzelnen Linux-Dienst neu starten],
    [3. Degradierter Betrieb und Retry: GPS, Netzwerk, Link],
    [2. Lokale Reinitialisierung: I2C/LCD, UART-Zustand],
    [1. Datenrahmen verwerfen: Prüfsumme, Länge, Syntax],
  )
  for (i, stufe) in stufen.enumerate() { knoten(u, 16, 2+i*12.5, 143, 10, stufe) }
  pfeil(u, ((7,75),(7,3)))
  beschriftung(u, 0, 81, 160, 7, [Steigende Eingriffstiefe von unten nach oben], groesse: 3)
})

#let zustandsautomat = flaeche(143, u => {
  knoten(u, 35, 3, 45, 13, [BOOT / DIAGNOSE], fett: true)
  beschriftung(u, 82, 0, 12, 5, [Start], groesse: 3)
  pfeil(u, ((95,6),(80,6)))
  knoten(u, 35, 39, 45, 13, [NORMAL], fett: true)
  knoten(u, 112, 39, 45, 13, [DEGRADED], fett: true)
  knoten(u, 35, 96, 45, 13, [ESKALATION], fett: true)
  knoten(u, 112, 96, 45, 13, [RECOVERY], fett: true)
  pfeil(u, ((56,16),(56,39)))
  marke(u, 58,25,[T1])
  pfeil(u, ((80,10),(135,10),(135,39)))
  marke(u, 107,7,[T2])
  pfeil(u, ((35,12),(22,12),(22,100),(35,100)))
  marke(u, 18,63,[T3])
  pfeil(u, ((80,45),(112,45)))
  marke(u, 91,39,[T4])
  pfeil(u, ((80,50),(117,96)))
  marke(u, 99,68,[T5])
  pfeil(u, ((56,52),(56,96)))
  marke(u, 58,70,[T6])
  pfeil(u, ((141,52),(141,96)))
  marke(u, 143,70,[T7])
  pfeil(u, ((112,100),(73,52)))
  marke(u, 81,72,[T8])
  pfeil(u, ((129,96),(129,52)))
  marke(u, 119,70,[T9])
  pfeil(u, ((135,109),(135,120),(58,120),(58,109)))
  marke(u, 91,117,[T10])
  pfeil(u, ((80,105),(112,105)))
  marke(u, 91,99,[T11])
  pfeil(u, ((35,106),(8,106),(8,6),(35,6)))
  marke(u, 3,36,[T12])
  beschriftung(u, 16, 129, 142, 13,
    [Abrupter Spannungsverlust beendet die Softwareausführung unabhängig vom Zustand.
    Nach stabiler Spannungsrückkehr beginnt der Ablauf erneut in BOOT.], groesse: 3)
})

#let bootablauf = flaeche(100, u => {
  let schritte = (
    [Reset / Power-on], [Clock, SysTick, UART, I2C, PVD],
    [Bootdiagnose und Resetursache], [Supervisor in Runtime konfigurieren],
    [APP_RUNTIME-Hauptschleife],
  )
  for (i, schritt) in schritte.enumerate() {
    knoten(u, 5, 3+i*20, 101, 13, schritt)
    if i < 4 { pfeil(u, ((55,16+i*20),(55,23+i*20))) }
  }
  pfeil(u, ((106,90),(150,90),(150,9),(106,9)))
  beschriftung(u, 109, 32, 37, 28, [IWDG-Reset bei\ fehlendem Fortschritt], groesse: 3.3)
})

#let balkendiagramm(werte, namen, achse) = flaeche(95, u => {
  let links = 15
  let rechts = 156
  let oben = 16
  let unten = 75
  let maximum = 36
  beschriftung(u, 0, 0, 160, 9, achse, groesse: 3.4)
  for tick in (0,10,20,30) {
    let y = unten - tick/maximum*(unten - oben)
    linie(u, (links,y),(rechts,y), farbe: luma(80%))
    beschriftung(u, 0, y - 3, 12, 6, str(tick), groesse: 3.2)
  }
  linie(u, (links,oben),(links,unten))
  linie(u, (links,unten),(rechts,unten))
  let schritt = (rechts - links)/werte.len()
  for (i, wert) in werte.enumerate() {
    let x = links+(i+0.5)*schritt
    let y = unten - wert/maximum*(unten - oben)
    place(top + left, dx: (x - 6)*u, dy: y*u,
      rect(width: 12*u, height: (unten - y)*u, fill: luma(80%), stroke: 0.55pt))
    beschriftung(u, x - 13,y - 7,26,6,str(wert).replace(".",","),groesse:3.3)
    beschriftung(u, x - schritt/2,78,schritt,14,namen.at(i),groesse:3.1)
  }
})
#let recoveryzeiten = balkendiagramm(
  (28.46,5.76,33.34,5.70),
  ([S1: GPS-Hänger],[S2: GPS-Absturz],[S3: UART-Hänger],[H1: STM32-Hänger]),
  [Mittlere funktionale Recovery [s]],
)
#let ausfallzeiten = balkendiagramm(
  (33,32,32), ([P1-01],[P1-02],[P1-03]), [Netzwerknichtverfügbarkeit [s]],
)

#let unterspannung = flaeche(119, u => {
  let links = 56
  let schritt = 16
  let oben = 12
  let unten = 84
  place(top + left, dx: links*u, dy: 5*u,
    rect(width: 80*u, height: 79*u, fill: luma(95%), stroke: none))
  let namen = (
    [STM32 vollständig aus],
    [STM32-Neustart; LCD aus],
    [STM32-Neustart; nur LCD-Hintergrundbeleuchtung],
    [Zeichen sichtbar; Hintergrundbeleuchtung schwächer],
    [Normalbetrieb von STM32 und LCD],
  )
  for (i, name) in namen.enumerate() {
    let y = unten - i*18
    linie(u,(links,y),(157,y),farbe:luma(80%))
    beschriftung(u,0,y - 7,52,14,name,groesse:3)
  }
  linie(u,(links,5),(links,unten))
  linie(u,(links,unten),(157,unten))
  linie(u,(136,5),(136,unten),gestrichelt:true)
  let stufen = (0,1,2,3,4,4,4)
  for (i, stufe) in stufen.enumerate() {
    let x = links+i*schritt
    let y = unten - stufe*18
    if i < 6 {
      linie(u,(x,y),(x+schritt,unten - stufen.at(i+1)*18),gestrichelt:true)
    }
    place(top+left,dx:(x - 1.2)*u,dy:(y - 1.2)*u,circle(radius:1.2*u,fill:black,stroke:none))
    beschriftung(u,x - 5,y - 7,10,5,[5/5],groesse:2.9)
    beschriftung(u,x - 5,86,10,5,str(i+2),groesse:3.3)
  }
  beschriftung(u,58,92,100,8,[Am Labornetzteil eingestellte VIN-Spannung [V]],groesse:3)
  beschriftung(u,56,70,77,9,[VIN < 7 V: außerhalb des spezifizierten Bereichs],groesse:2.8)
  beschriftung(u,0,103,160,14,[Qualitative Zustandsklassen (ordinal). Die gestrichelte Verbindung zeigt nur die
    Reihenfolge der Messstufen und bestimmt keine Schwellenspannung.],groesse:3)
})

#let diagramme = (
  "abb-3-1.png": architektur,
  "abb-3-2.png": dienste,
  "abb-3-3.png": eskalation,
  "abb-3-4.png": zustandsautomat,
  "abb-4-1.png": bootablauf,
  "abb-5-1.png": recoveryzeiten,
  "abb-5-2.png": ausfallzeiten,
  "abb-5-3.png": unterspannung,
)
