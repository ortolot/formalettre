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
  signature: "",
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

// Known envelope formats
#let formats_enveloppe = (
    c4: (width: 32.4cm, height: 22.9cm),
    c5: (width: 22.9cm, height: 16.2cm),
    c6: (width: 16.2cm, height: 11.4cm),
    c56: (width: 22.9cm, height: 11.4cm),
    dl: (width: 22cm, height: 11cm))

// Parse an envelope format specification and return a format
// dictionary. The specification can be:
// * a string containing the name of a known format, e.g. "c4" or "dl";
// * a tuple (<width>, <height>);
// * a format dictionary (width: <width>, height: <height>).
#let parse_format(spec) = {
    let format = (:)
    if type(spec) == str {
        format = formats_enveloppe.at(
            lower(spec),
            default: none)
        if format == none {
            panic("unknown format " + spec)
        }
    }
    else if type(spec) == array {
        format.width = spec.at(0)
        format.height = spec.at(1)
    }
    else if type(spec) == dict {
        format.width = spec.width
        format.height = spec.height
    }
    else {
        panic("enveloppe spec should be a known format, (<width>, <height>) or (width: <width>, height: <height>")
    }
    return format
}

#let not_empty(something) = {
    something != "" and something != [] and something != none
}

#let lettre(
    expediteur: expediteur,
    destinataire: destinataire,
    envoi: [],
    objet: [],
    date: [],
    lieu: [],
    ref: "",
    vref: "",
    nref: "",
    appel: "",
    salutation: "",
    ps: [],
    pj: [],
    cc: [],
    marque_pliage: false,
    enveloppe: none,
    affranchissement: none,
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
    expediteur.signature = expediteur.at(
        "signature",
        default: [#expediteur.prenom #smallcaps(expediteur.nom)])
    if type(expediteur.signature) == bool {
        expediteur.signature = [
            #v(-3cm)
            #expediteur.prenom #smallcaps(expediteur.nom)
        ]
    }
    expediteur.image_signature = expediteur.at("image_signature", default: [])
    // destinataire.titre is required
    // destinataire.voie is required
    destinataire.complement_adresse = destinataire.at("complement_adresse", default: "")
    // destinataire.code_postal is required
    // destinataire.commune is required
    destinataire.pays = destinataire.at("pays", default: "")
    destinataire.sc = destinataire.at("sc", default: "")

    // Bloc d'adresse de l'expéditeur, utilisable pour l'en-tête et l'enveloppe
    expediteur.adresse = [
        #expediteur.prenom #smallcaps(expediteur.nom) \
        #expediteur.voie \
        #if not_empty(expediteur.complement_adresse) [
            #expediteur.complement_adresse \
        ]
        #expediteur.code_postal #expediteur.commune
        #if not_empty(expediteur.pays) {
            linebreak()
            smallcaps(expediteur.pays)
        }
    ]

    // Bloc de coordonnées de l'expéditeur, utilisées dans l'en-tête
    if expediteur.telephone == "" and expediteur.email == "" {
        expediteur.coordonnees = []
    }
    else {
        expediteur.coordonnees = {
            if expediteur.telephone != "" [
                tél. : #link(
                    "tel:"+ expediteur.telephone.replace(" ", "-"),
                    expediteur.telephone) \
            ]
            if expediteur.email != "" [
                email : #link(
                    "mailto:" + expediteur.email,
                    raw(expediteur.email)) \
            ]
        }
    }

    // Bloc d'adresse du destinataire, utilisable pour l'en-tête et l'enveloppe
    destinataire.adresse = [
        #destinataire.titre \
        #destinataire.voie \
        #if not_empty(destinataire.complement_adresse) [
            #destinataire.complement_adresse \
        ]
        #destinataire.code_postal #destinataire.commune
        #if not_empty(destinataire.pays) {
            linebreak()
            smallcaps(destinataire.pays)
        }
        #if not_empty(destinataire.sc) [
            #v(2.5em)
            s/c de #destinataire.sc \
        ]
    ]

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
    // 25mm│ 75mm = 46.875% 1fr     auto    1fr│25mm
    //     └───────────────────────────────────┘
    //                      100%
    //
    // For the sender column, we use a percentage instead of a fixed length.
    // That percentage has been computed to result in the same length with an
    // A4 page using standard Typst margins. This allows us to produce a
    // relevant layout even with page sizes othen than A4, e.g. letter or A5
    // (although there will be no compatibility with windowed enveloppe with
    // such a small format).
    //
    block(width: 100%, height: 75mm, spacing: 0pt,
        grid(
            columns: (46.875%, 1fr, auto, 1fr),
            rows: (20mm, 1fr, auto, 1fr, 20mm),
            grid.cell(rowspan: 4,  // sender address and contact info
                [
                    #expediteur.adresse
                    #if expediteur.coordonnees != [] {
                        par(expediteur.coordonnees)
                    }
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
            grid.cell(colspan: 3, []),         // filler #1
            grid.cell[],                       // filler #2
            grid.cell[#destinataire.adresse],  // sender address
            grid.cell[],                       // filler #3
            grid.cell(colspan: 3, []),         // filler #4
            grid.cell(colspan: 4, []),         // filler #5
        )
    )

    if marque_pliage {
        place(
            top + left, dx: -25mm, dy: 74mm,
            line(length: 1cm, stroke: .1pt))
    }

    v(1em)
    if not_empty(envoi) {
        par(envoi)
    }
    if objet != "" and objet != [] [
        *Objet : #objet*
        #v(1.8em)
    ]

    if ref != "" [
        Réf. #ref
        #v(1em)
    ]
    else if vref != "" and nref != "" [
        V/réf. #vref
        #h(1fr)
        N/Réf. #nref
        #h(3fr)
        #v(1em)
    ]
    else if vref != "" [
        V/réf. #vref \
        #v(1em)
    ]
    else if nref != "" [
        N/réf. #nref \
        #v(1em)
    ]

    [*Objet : #objet*]
    
    v(1.8em)

    set par(justify: true)

    if appel != "" {
        appel
        v(1em)
    }

    doc

    block(
        breakable: false,
        {
            if salutation != "" {
                v(1em)
                salutation
            }

            let hauteur_signature = 3cm
            if expediteur.image_signature != [] {
                hauteur_signature = auto
            }

            grid(
                columns: (1fr, 1fr),
                rows: (hauteur_signature, auto),
                grid.cell(rowspan: 2)[],
                grid.cell[
                    #set align(center + horizon)
                    #expediteur.image_signature
                ],
                grid.cell[
                    #set align(center)
                    #expediteur.signature
                ]
            )
        }
    )

    if not_empty(ps) or not_empty(pj) or not_empty(cc) {
        let width = 2.5em
        let mentions = ()

        if not_empty(ps) and type(ps) == content or type(ps) == str {
            mentions.push("P.-S.")
            mentions.push(ps)
        }
        else if type(ps) == array {
            width = 1.3em
            let prefix = "S."
            for item in ps {
                width += 1.2em
                prefix = "P.-" + prefix
                mentions.push(prefix)
                mentions.push(item)
            }
        }
        else if type(ps) == dictionary {
            for (prefix, item) in ps {
                mentions.push(prefix)
                mentions.push(item)
            }
        }

        if not_empty(ps) and type(pj) == content or type(pj) == str {
            mentions.push("P. j.")
            mentions.push(pj)
        }
        else if type(pj) == array {
            mentions.push("P. j.")
            mentions.push(list(marker: [], body-indent: 0pt, ..pj))
        }

        if not_empty(cc) and type(cc) == content or type(cc) == str {
            mentions.push("C. c.")
            mentions.push(cc)
        }
        else if type(cc) == array {
            mentions.push("C. c.")
            mentions.push(list(marker: [], body-indent: 0pt, ..cc))
        }

        v(2.5em)
        grid(
            columns: (width, 1fr),
            row-gutter: 1.5em,
            ..mentions
        )
    }

    if enveloppe != none {
        let format = parse_format(enveloppe)

        pagebreak()

        set page(
            width: format.width, height: format.height)

        // Set text size to an appropriate value for the chosen envelope
        // size. It must grow with the envelope size, but not too much
        // to avoid getting weirdly bit font with the largest formats.
        // Square root seems to give an appropriate growth rate. It has
        // been adjusted for using 11pt with the smallest, c6 envelope.
        set text(size: calc.sqrt(format.height.cm() / 11) * 11pt)

        // We use the following grid layout:
        //              1fr              auto
        //     ┌────────────────────┬─────────────┐
        // ┌──────────────────────────────────────────┐
        // │             default margin               │
        // │   ┌────────────────────┬─────────────┐   │ ┐
        // │   │ Sender             │             │   │ │
        // │   │ Address            │             │   │ │
        // │   │                    │             │   │ │ 6fr
        // │   │                    │             │   │ │
        // │   │                    │             │   │ │
        // │   ├──────────────┬─────┴────────┬────┤   │ ┤
        // │   │    filler    │ Recipient    │ f. │   │ │ auto
        // │   │    #1        │ Address      │ #2 │   │ │
        // │   ├──────────────┴──────────────┴────┤   │ ┘
        // │   │            filler #3             │   │
        // └───┴──────────────────────────────────┴───┘
        //     └──────────────┴──────────────┴────┘
        //            3fr           auto      1fr
        //
        grid(
            columns: (3fr, auto, 1fr),
            rows: (6fr, auto, 1fr),
            grid.cell(colspan: 3,      // sender + stamp line
                grid(
                    columns: (1fr, auto),
                    grid.cell[         // sender block
                        #set align(left + top)
                        Expéditeur :\
                        #expediteur.adresse
                    ],
                    grid.cell[         // stamp block
                        #set align(right + top)
                        #if affranchissement != none {
                            affranchissement
                        }
                    ]
                )
            ),
            grid.cell[],               // filler #1
            grid.cell[                 // recipient block
                #set align(left + horizon)
                #destinataire.adresse
            ],
            grid.cell[],               // filler #2
            grid.cell(colspan: 3, [])  // filler #3
        )
    }
}
