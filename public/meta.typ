#set page(
  paper: "a4",
  width: 1200pt,
  height: 630pt,
  margin: (x: 1.8cm, y: 1.5cm),
  fill: rgb("#f5f5f1")
)

#set text(
  font: "JetBrains Mono NL",
  size: 11pt,
)

#show link: it => underline(
  stroke: 0.5pt + rgb("#f5f5f1"),
  offset: 2pt,
  it
)
#show link: set text(size: 40pt, fill: rgb("#171916"))

#page(
  background: {
    let tile = tiling(size: (12pt, 12pt))[
      #place(
        top + left,
        dx: 6pt, dy: 6pt,
        circle(radius: 0.8pt, fill: rgb("#004500"))
      )
    ]

    place(top + left, rect(width: 100%, height: 100%, fill: tile))
  },
  header: none,
  footer: none
)[
  #set align(center + horizon)
  #text(size: 80pt, weight: "bold", fill: rgb("#171916"))[
    Lifestyle creep is real, Step up SIP is the answer
  ]
  #rect(width: 40mm, height: 3pt, fill: rgb("#d9ff43"))
  #set align(center + bottom)
  #link("https://sip.rakshithnettar.com")
]
