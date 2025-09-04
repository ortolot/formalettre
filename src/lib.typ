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

    // An windowed enveloppe looks like this:
    //                          220 mm
    //       ┌───────────────────────────────────────────┐
    //     ┌ ┌───────────────────────────────────────────┐ ┐
    //     │ │                                           │ │
    //     │ │                                           │ │ 45 mm
    //     │ │                                           │ │
    //     │ │                   ┌───────────────────┐   │ ┤
    // 110 │ │                   │                   │   │ │
    //  mm │ │                   │                   │   │ │ 45 mm
    //     │ │                   │                   │   │ │
    //     │ │                   └───────────────────┘   │ ┤
    //     │ │                                           │ │ 20 mm
    //     └ └───────────────────────────────────────────┘ ┘
    //       └───────────────────┴───────────────────┴───┘
    //            100 mm              100 mm      20 mm
    //
    // The folded letter is 210 mm large and 99 mm high, and can
    // therefore more horizontally by 10 mm and vertically by 11 mm.
    // This results in the following safe zone for the recipient
    // address:
    // ┌───────────────────────────────────────────┐ ┐
    // │                                           │ │
    // │                                           │ │ 45 mm
    // │                                           │ │
    // │                   ┌───────────────────┐   │ ┤
    // │                   │                   │   │ │ 34 mm
    // │                   │                   │   │ │
    // │                   └───────────────────┘   │ ┤
    // │                                           │ │ 20 mm
    // └─────────────── fold ── here ──────────────┘ ┘
    // └───────────────────┴───────────────────┴───┘
    //         100 mm              90 mm       20 mm
    //
    // We use a (width: 100%, height: 100mm) box containing a grid with
    // some merged cells to position sender, place and date, and
    // recipient. Filling rows and columns with fractional dimensions
    // are here to center the recipient address block within its
    // window, resulting in a much better-looking layout than just
    // positionning it statically.
    // ┌───────────────────────────────────────────┐ ┐
    // │                  margin                   │ │ 25 mm
    // │   ┌───────────────┬───────────────────┐   │ ┤ ──────┐
    // │   │ Sender        │       place, date │   │ │ 20 mm │
    // │   │ Address       ├───────────────────┤   │ ┤       │
    // │   │               │     filler #1     │   │ │ 1fr   │
    // │   │ Phone         ├───┬───────────┬───┤   │ ┤       │
    // │   │ Email         │f. │ Recipient │f. │   │ │ auto  │
    // │   │               │#2 │ Address   │#3 │   │ │       │ 75 mm
    // │   │               ├───┴───────────┴───┤   │ ┤       │
    // │   │               │     filler #4     │   │ │ 1fr   │
    // │   ├───────────────┴───────────────────┤   │ ┤       │
    // │   │            filler #5              │   │ │ 20 mm │
    // └───┴───────────────────────────────────┴───┘ ┘ ──────┘
    // └───┴───────────────┴───┴───────────┴───┴───┘
    // 25mm│     75mm       1fr     auto    1fr│25mm
    //     └───────────────────────────────────┘
    //                      100%
    //
    block(width: 100%, height: 75mm, spacing: 0pt,
        grid(
            columns: (75mm, 1fr, auto, 1fr),
            rows: (20mm, 1fr, auto, 1fr, 20mm),
            grid.cell(rowspan: 4,  // sender address and contact info
                [
                    #expediteur.prenom #smallcaps(expediteur.nom) \
                    #expediteur.voie \
                    #if expediteur.complement_adresse != "" and expediteur.complement_adresse != [] [
                        #expediteur.complement_adresse \
                    ]
                    #expediteur.code_postal #expediteur.commune
                    #if expediteur.pays != "" and expediteur.pays != [] {
                        linebreak()
                        smallcaps(expediteur.pays)
                    }
                    #if expediteur.telephone != "" [
                        #linebreak()
                        tél. : #link(
                            "tel:"+ expediteur.telephone.replace(" ", "-"),
                            expediteur.telephone)
                    ]
                    #if expediteur.email != "" [
                        #linebreak()
                        email : #link("mailto:" + expediteur.email, raw(expediteur.email))
                    ]
                ]
            ),
            grid.cell(colspan: 3,  // place and date
                [
                    #set align(right)
                    // place and date should be on second line
                    #linebreak()
                    #lieu, #date
                ]
            ),
            grid.cell(colspan: 3, []),  // filler #1
            grid.cell[],                // filler #2
            grid.cell[                  // sender address
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
            grid.cell[],               // filler #3
            grid.cell(colspan: 3, []), // filler #4
            grid.cell(colspan: 4, []), // filler #5
        )
    )

    v(1em)
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
