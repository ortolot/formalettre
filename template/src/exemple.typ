#import "@preview/formalettre:0.1.3": *

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  prenom: "Étienne",
  nom: "de La Boétie",
  voie: "145 avenue de Germignan",
  complement_adresse: "",
  code_postal: "33320",
  commune: "Le Taillan-Médoc",
  telephone: "01 99 00 67 89",
  email: "etienne@laboetie.example",
  signature: "Étienne", // par défaut, reprend le prénom et le nom
  // Décommenter la ligne suivante pour inclure l'image d'une signature
  // numérisée
  // image_signature: image("signature.png")
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
// Décommenter la ligne suivante pour afficher des informations d'envoi suivi
// ou recommandé
// envoi: [Lettre suivie numéro XXXXXXXX],
ref: "1559/06/0001",    // au besoin, préciser à la place
                        // vref: "<réf. destinataire>
                        // nref: "<réf. expéditeur>
appel: "Cher ami,",
salutation: "Veuillez agréer, cher ami, l'assurance de mes chaleureuses salutations.",
ps: "Au fait, notez bien notre prochain rendez-vous !",
// Décommentez la ligne suivante pour préciser des pièces jointes
// pj: ("Photo de famille", "Copie de mon dernier essai")
cc: [],
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
