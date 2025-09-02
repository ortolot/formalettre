#let expediteur = (
  nom: [],
  prenom: [],
  voie: [],
  complement_adresse: [],
  code_postal: [],
  commune: [],
  pays: [],
  telephone: "",  // string, not content: will be processed
  email: "",      // string, not content: will be processed
  signature: false,
)

#let destinataire = (
    titre: [],
    voie: [],
    complement_adresse: [],
    code_postal: [],
    commune: [],
    pays: [],
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
    // expediteur.prenom is required
    // expediteur.nom is required
    expediteur.complement_adresse = expediteur.at("complement_adresse", default: "")
    // expediteur.voie is required
    // expediteur.code_postal is required
    // expediteur.commune is required
    expediteur.pays = expediteur.at("pays", default: "")
    expediteur.telephone = expediteur.at("telephone", default: "")
    expediteur.email = expediteur.at("email", default: "")
    expediteur.signature = expediteur.at("signature", default: false)
    // destinataire.titre is required
    // destinataire.voie is required
    destinataire.complement_adresse = destinataire.at("complement_adresse", default: "")
    // destinataire.code_postal is required
    // destinataire.commune is required
    destinataire.pays = destinataire.at("pays", default: "")
    destinataire.sc = destinataire.at("sc", default: "")
    [
        #expediteur.prenom #smallcaps(expediteur.nom) \
        #expediteur.voie #h(1fr) #lieu, #date \
    ]
    if expediteur.complement_adresse != "" and expediteur.complement_adresse != [] [
        #expediteur.complement_adresse \
    ]
    [
        #expediteur.code_postal #expediteur.commune
    ]
    if expediteur.pays != "" and expediteur.pays != [] {
        linebreak()
        smallcaps(expediteur.pays)
    }
    if expediteur.telephone != "" [
        #linebreak()
        tél. : #link(
            "tel:"+ expediteur.telephone.replace(" ", "-"),
            expediteur.telephone)
    ]
    if expediteur.email != "" [
        #linebreak()
        email : #link("mailto:" + expediteur.email, raw(expediteur.email))
    ]
    v(1cm)

    grid(
        columns: (1fr, 5cm),
        grid.cell(""),
        [
            #destinataire.titre \
            #destinataire.voie \
            #if destinataire.complement_adresse != "" and destinataire.complement_adresse != [] [
                #destinataire.complement_adresse \
            ]
            #destinataire.code_postal #destinataire.commune
            #if destinataire.sc != "" and destinataire.sc != [] [
                #v(1cm)
                s/c de #destinataire.sc \
            ]
        ],
    )

    v(1.7cm)

    [*Objet : #objet*]
    
    v(0.7cm)

    set par(justify: true)
    doc
    if pj != "" and pj != [] {
        [
            #v(1cm)
            P. j. : #pj
        ]
    }
set align(right + horizon)
    if expediteur.signature {
        v(-3cm)
    }
    [
        #expediteur.prenom #smallcaps[#expediteur.nom]
    ]
}
