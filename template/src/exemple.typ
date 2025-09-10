#import "@preview/formalettre:0.1.3": *

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  nom: [Étienne #smallcaps[de la Boétie]],
  adresse: [145 avenue de Germignan],
  commune: [33320 Le Taillan-Médoc],
  telephone: "01 99 00 67 89",
  email: "etienne@laboetie.example",
  // Décommenter la ligne suivante pour utiliser autre chose que le prénom et
  // le nom dans la signature
  // signature: "Étienne",
  // Décommenter la ligne suivante pour inclure l'image d'une signature
  // numérisée
  // image_signature: image("signature.png")
),
destinataire: (
  nom: [Michel de Montaigne],
  adresse: [17 butte Farémont],
  commune: [55000 Bar-le-Duc],
  // Décommenter la ligne suivante pour include une mention s/c
  // d'envoi par voie hiérarchique (sous couvert de)
  // sc: "Quelqu'un",
),
lieu: "Camp Germignan",
objet: [Ceci est un objet de courrier.],
date: [le 7 juin 1559],
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
