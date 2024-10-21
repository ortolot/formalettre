#let expediteur = (
  name: [],
  first_name: [],
  street: [],
  complement_adresse: [],
  zipcode: [],
  city: [],
  telephone: [],
  email: [],
)

#let destinataire = (
    title: [],
    street: [],
    complement_adresse: [],
    zipcode: [],
    city: [],
    sc: [],
)


#let lettre(
    expediteur: expediteur,
    destinataire: destinataire,
    objet: [],
    date: [],
    lieu: [],
    pj: [],
    doc,
) = {
    [
        #expediteur.first_name #smallcaps[#expediteur.name] \
        #expediteur.street #h(1fr) #lieu, #date \
    ]
    if expediteur.complement_adresse != "" {
        [
            #expediteur.complement_adresse
            #linebreak()
        ]
    }
    [
        #expediteur.zipcode #expediteur.city
    ]
    if expediteur.telephone != "" {
        [
            #linebreak()
            tél. : #raw(expediteur.telephone)
        ]
    }
    if expediteur.email != "" {
        [
            #linebreak()
            email: #link("mailto:" + expediteur.email)[#raw(expediteur.email)]
        ]
    }
    v(1cm)

    grid(
        columns: (1fr, 7cm),
        grid.cell(""),
        [
            #destinataire.title \
            #destinataire.street \
            #if destinataire.complement_adresse != "" {
                [
                    #destinataire.complement_adresse \
                ]
            }
            #destinataire.zipcode #destinataire.city
            #if destinataire.sc != "" {
                [
                    #v(1cm)
                    s/c de #destinataire.sc \
                ]
            }
        ],
    )

    v(2cm)

    [*Objet : objet*]

    set par(justify: true)
    doc
    if pj != "" {
        [
            #v(1cm)
            P. j. : #pj
        ]
    }
    set align(right + bottom)
    [
        #expediteur.first_name #smallcaps[#expediteur.name]
    ] 
}
