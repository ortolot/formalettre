#let expediteur = (
  nom: [],
  adresse: (),        // actually optional, see below
  commune: [],
  // pays: [],        // optional
  // telephone: "",   // string, not content: will be processed; optional
  // email: "",       // string, not content: will be processed; optional
  // signature: [],   // optional
)


#let destinataire = (
    nom: [],
    adresse: (),  // actually optional, see below
    commune: [],
    // pays: [],  // optional
    // sc: [],    // sous couvert; optional
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

#let is_empty(something) = {
    something == "" or something == [] or something == none
}

#let not_empty(something) = {
    something != "" and something != [] and something != none
}

// (Small-)capitalize content if the capitalization level is above a minimum
// value
#let capitalise(cap_level, min_level, content) = {
    let cap = smallcaps
    if calc.fract(cap_level) != 0 {
        cap = upper
    }
    if cap_level >= min_level {
        return cap(content)
    }
    else {
        return content
    }
}

#let bloc_adresse(personne, capitalisation: 0) = [
    #capitalise(capitalisation, 3, personne.nom) \
    #for ligne in personne.adresse [
        #capitalise(capitalisation, 2, ligne) \
    ]
    #capitalise(capitalisation, 1, personne.commune) \
    #if not_empty(personne.pays) [
        #capitalise(capitalisation, 1, personne.pays) \
    ]
]

#let lettre(
    expediteur: expediteur,
    destinataire: destinataire,
    objet: [],
    date: [],
    lieu: [],
    appel: "",
    salutation: "",
    pj: [],
    marque_pliage: false,
    enveloppe: none,
    affranchissement: none,
    capitalisation: 0,
    doc,
) = {
    // Convert legacy sender fields
    if "prenom" in expediteur {
        expediteur.nom = [#expediteur.remove("prenom") #smallcaps(expediteur.nom)]
    }
    if "voie" in expediteur {
        expediteur.adresse = (expediteur.remove("voie"),)
        if "complement_adresse" in expediteur and not_empty(expediteur.complement_adresse) {
            expediteur.adresse.push(expediteur.remove("complement_adresse"))
        }
    }
    if "code_postal" in expediteur {
        expediteur.commune = [#expediteur.remove("code_postal") #expediteur.commune]
    }

    // Convert legacy recipient fields
    if "titre" in destinataire {
        destinataire.nom = destinataire.remove("titre")
    }
    if "voie" in destinataire {
        destinataire.adresse = (destinataire.remove("voie"),)
        if "complement_adresse" in destinataire and not_empty(destinataire.complement_adresse) {
            destinataire.adresse.push(destinataire.remove("complement_adresse"))
        }
    }
    if "code_postal" in destinataire {
        destinataire.commune = [#destinataire.remove("code_postal") #destinataire.commune]
    }

    // Set default values for sender optional fields
    // expediteur.nom is required
    // expediteur.adresse is optional as there exist organization with only a
    // name and a locality.
    if "adresse" not in expediteur or is_empty(expediteur.adresse) {
        expediteur.adresse = ()
    }
    // expediteur.adresse may alse be a simple string or content,
    // convert it to a list
    else if type(expediteur.adresse) == str or type(expediteur.adresse) == content {
        expediteur.adresse = (expediteur.adresse,)
    }
    // expediteur.commune is required
    expediteur.pays = expediteur.at("pays", default: none)
    expediteur.telephone = expediteur.at("telephone", default: none)
    expediteur.email = expediteur.at("email", default: none)
    expediteur.signature = expediteur.at(
        "signature",
        default: expediteur.nom)
    if type(expediteur.signature) == bool {
        expediteur.signature = [
            #v(-3cm)
            #expediteur.nom
        ]
    }
    expediteur.image_signature = expediteur.at("image_signature", default: none)

    // Set default values for recipient-specific optional fields
    // destinataire.nom is required
    // destinataire.adresse is optional as there exist organization with only a
    // name and a locality.
    if "adresse" not in destinataire or is_empty(destinataire.adresse) {
        destinataire.adresse = ()
    }
    // destinataire.adresse may alse be a simple string or content,
    // convert it to a list
    else if type(destinataire.adresse) == str or type(destinataire.adresse) == content {
        destinataire.adresse = (destinataire.adresse,)
    }
    // destinataire.commune is required
    destinataire.pays = destinataire.at("pays", default: none)
    destinataire.sc = destinataire.at("sc", default: none)

    // Bloc d'adresse de l'expéditeur, utilisable pour l'en-tête et l'enveloppe
    expediteur.bloc_adresse = bloc_adresse(expediteur, capitalisation: capitalisation)

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
    destinataire.bloc_adresse = [
        #bloc_adresse(destinataire, capitalisation: capitalisation)
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
            grid.cell(rowspan: 4, {  // sender address and contact info
                if enveloppe == none {
                    bloc_adresse(expediteur, capitalisation: capitalisation)
                } else {
                    bloc_adresse(expediteur)
                }
                if expediteur.coordonnees != [] {
                    par(expediteur.coordonnees)
                }
            }),
            grid.cell(colspan: 3,  // place and date
                [
                    #set align(right)
                    // place and date should be on second line
                    #linebreak()
                    #lieu, #date
                ]
            ),
            grid.cell(colspan: 3, []),              // filler #1
            grid.cell[],                            // filler #2
            grid.cell({                             // sender address
                if enveloppe == none {
                    bloc_adresse(destinataire, capitalisation: capitalisation)
                } else {
                    bloc_adresse(destinataire)
                }
                if not_empty(destinataire.sc) [
                    #v(2.5em)
                    s/c de #destinataire.sc \
                ]
            }),
            grid.cell[],                            // filler #3
            grid.cell(colspan: 3, []),              // filler #4
            grid.cell(colspan: 4, []),              // filler #5
        )
    )

    if marque_pliage {
        place(
            top + left, dx: -25mm, dy: 74mm,
            line(length: 1cm, stroke: .1pt))
    }

    v(1em)
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

    if pj != "" and pj != [] {
        [
            #v(2.5em)
            P. j. : #pj
        ]
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
                        #bloc_adresse(expediteur, capitalisation: capitalisation)
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
                #bloc_adresse(destinataire, capitalisation: capitalisation)
            ],
            grid.cell[],               // filler #2
            grid.cell(colspan: 3, [])  // filler #3
        )
    }
}
