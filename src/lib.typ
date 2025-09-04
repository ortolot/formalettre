#let expediteur = (
  nom: [],
  prenom: [],
  voie: [],
  complement_adresse: [],
  code_postal: [],
  commune: [],
  telephone: [],
  email: [],
  signature: false,
)

#let destinataire = (
    titre: [],
    voie: [],
    complement_adresse: [],
    code_postal: [],
    commune: [],
    sc: [],
)


#let lettre(
    expediteur: expediteur,
    destinataire: destinataire,
    objet: [],
    date: [],
    lieu: [],
    appel: "",
    salutation: "",
    pj: [],
    doc,
) = {
    [
        #expediteur.prenom #smallcaps[#expediteur.nom] \
        #expediteur.voie #h(1fr) #lieu, #date \
    ]
    if expediteur.complement_adresse != "" {
        [
            #expediteur.complement_adresse
            #linebreak()
        ]
    }
    [
        #expediteur.code_postal #expediteur.commune
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
            email : #link("mailto:" + expediteur.email)[#raw(expediteur.email)]
        ]
    }
    v(1cm)

    grid(
        columns: (1fr, 5cm),
        grid.cell(""),
        [
            #destinataire.titre \
            #destinataire.voie \
            #if destinataire.complement_adresse != "" {
                [
                    #destinataire.complement_adresse \
                ]
            }
            #destinataire.code_postal #destinataire.commune
            #if destinataire.sc != "" {
                [
                    #v(2.5em)
                    s/c de #destinataire.sc \
                ]
            }
        ],
    )

    v(1.7cm)

    [*Objet : #objet*]
    
    v(1.8em)

    set par(justify: true)

    if appel != "" {
        appel
        v(1em)
    }

    doc

    if salutation != "" {
        v(1em)
        salutation
    }

    if pj != "" {
        [
            #v(2.5em)
            P. j. : #pj
        ]
    }
set align(right + horizon)
    if expediteur.signature == true {
        v(-3cm)
    }
    [
        #expediteur.prenom #smallcaps[#expediteur.nom]
    ]
}
