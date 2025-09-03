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

#let lettre(
    expediteur: expediteur,
    destinataire: destinataire,
    objet: [],
    date: [],
    lieu: [],
    pj: [],
    enveloppe: none,
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
    {
        set align(right + horizon)
        if expediteur.signature == true {
            v(-3cm)
        }
        [
            #expediteur.prenom #smallcaps[#expediteur.nom]
        ]
    }

    if enveloppe != none {
        let format = parse_format(enveloppe)
        pagebreak()
        set page(
            width: format.width, height: format.height,
            margin: (left: 1cm, top: 1cm, rest: 2cm))
        // Set text size to an appropriate value for the chosen envelope
        // size. It must grow with the envelope size, but not too much
        // to avoid getting weirdly bit font with the largest formats.
        // Square root seems to give an appropriate growth rate. It has
        // been adjusted for using 11pt with the smallest, c6 envelope.
        set text(size: calc.sqrt(format.height.cm() / 11) * 11pt)
        grid(
            columns: (3fr, auto, 1fr),
            rows: (6fr, auto, 1fr),
            grid.cell(colspan: 3)[
                #set align(left + top)
                Expéditeur :\
                #expediteur.prenom #expediteur.nom \
                #expediteur.voie \
                #if expediteur.complement_adresse != "" [
                    #expediteur.complement_adresse \
                ]
                #expediteur.code_postal #expediteur.commune
            ],
            grid.cell[],
            grid.cell[
                #set align(left + horizon)
                Destinataire :\
                #destinataire.titre \
                #destinataire.voie \
                #if destinataire.complement_adresse != "" [
                    #destinataire.complement_adresse \
                ]
                #expediteur.code_postal #expediteur.commune
            ],
            grid.cell[],
            grid.cell(colspan: 3, [])
        )
    }
}
