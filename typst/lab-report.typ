#let lab-report(
  title: none,
  authors: (),
  supervisor: (),
  groupnumber: none,
  date: datetime.today(),
  language: "en",
  doc,
) = {
  set page(paper: "a4")
  set text(lang: language, font: "New Computer Modern", size: 11pt)

  set align(center)

  image(width: 10cm, "assets/tuw_logo.jpg")

  v(3cm)

  text(size: 18pt)[
    #smallcaps[Vienna University of Technology\
    ]]
  v(0.2cm)
  text(size: 16pt)[
    #smallcaps[Faculty of Physics\
    ]]
  v(0.2cm)
  text(size: 14pt)[
    #smallcaps[Laboratory III\
    ]]
  v(2cm)
  line(length: 100%)
  text(size: 24pt, weight: "bold")[Laboratory Report\ #v(0.2cm)]
  text(size: 18pt)[#title]
  line(length: 100%)
  v(1fr)
  grid(
    columns: (1fr, 1fr),
  )[
    #set align(left)
    #set text(size: 12pt)
    #text(weight: "bold")[
      Authors: \
    ]
    #authors.join("\n")\
    #text(weight: "bold")[
      Group #groupnumber
    ]
  ][
    #set align(right)
    #set text(size: 12pt)
    #text(weight: "bold")[
      Supervisor:\
    ]
    #supervisor
  ]
  v(1cm)

  text[conducted on:\ ]
  date.display("[day] [month repr:long] [year]")

  pagebreak()

  set align(left)
  set par(justify: true)

  counter(page).update(1)
  set page(
    numbering: "1",
    header: [
      #set align(center)
      Laboratory Work III - #title],
  )

  doc
}