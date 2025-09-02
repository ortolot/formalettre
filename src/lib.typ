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
    pj: [],
    doc,
) = {
    [
        #expediteur.prenom #smallcaps[#expediteur.nom] \
        #expediteur.voie #h(1fr) #lieu, #date \
    ]
    if expediteur.at("complement_adresse", default: "") != "" {
        [
            #expediteur.complement_adresse
            #linebreak()
        ]
    }
    [
        #expediteur.code_postal #expediteur.commune
    ]
    if expediteur.at("pays", default: "") != "" {
        linebreak()
        smallcaps(expediteur.pays)
    }
    if expediteur.at("telephone", default: "") != "" {
        [
            #linebreak()
            tél. : #raw(expediteur.telephone)
        ]
    }
    if expediteur.at("email", default: "") != "" {
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
            #if destinataire.at("complement_adresse", default: "") != "" {
                [
                    #destinataire.complement_adresse \
                ]
            }
            #destinataire.code_postal #destinataire.commune
            #if destinataire.at("sc", default: "") != "" {
                [
                    #v(1cm)
                    s/c de #destinataire.sc \
                ]
            }
        ],
    )

    v(1.7cm)

    [*Objet : #objet*]
    
    v(0.7cm)

    set par(justify: true)
    doc
    if pj != "" {
        [
            #v(1cm)
            P. j. : #pj
        ]
    }
set align(right + horizon)
    if expediteur.at("signature", default: false) == true {
        v(-3cm)
    }
    [
        #expediteur.prenom #smallcaps[#expediteur.nom]
    ]
}
