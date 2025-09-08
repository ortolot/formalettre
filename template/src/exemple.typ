#import "@preview/formalettre:0.1.3": *

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  nom: "de La Boétie",
  prenom: "Étienne",
  voie: "145 avenue de Germignan",
  complement_adresse: "",
  code_postal: "33320",
  commune: "Le Taillan-Médoc",
  telephone: "01 99 00 67 89",
  email: "etienne@laboetie.example",
  signature: false, // indiquez true si ajout d’une image comme signature
),
destinataire: (
  titre: "Michel de Montaigne",
  voie: "17 butte Farémont",
  complement_adresse: "",
  code_postal: "55000",
  commune: "Bar-le-Duc",
  sc: "",
),
lieu: "Camp Germignan",
objet: [Ceci est un objet de courrier.],
date: [le 7 juin 1559],
ref: "1559/06/0001",    // au besoin, préciser à la place
                        // vref: "<réf. destinataire>
                        // nref: "<réf. expéditeur>
appel: "Cher ami,",
salutation: "Veuillez agréer, cher ami, l'assurance de mes chaleureuses salutations.",
pj: "",
marque_pliage: false,   // indiquez true pour imprimer une marque de pliage
                        //
enveloppe: none,        // indiquez un format d'enveloppe, par exemple
                        // "c4", "c5", "c6", "c56" ou "dl"
                        // pour générer une page à imprimer sur enveloppe,
                        //
affranchissement: none, // fournir un code d'affranchissement ou un contenu
                        // d'image de timbre pour qu'il soit imprimé
                        // dans la zone idoine de l'enveloppe
)

// Le corps du document remplace cette fonction
#lorem(200)


// Décommenter ces deux lignes pour ajouter la signature sous forme d’image
//#set align(right + horizon)
//#image("Signature.png")
