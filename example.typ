#import "lib.typ": lettre

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  name: "de La Boétie",
  first_name: "Étienne",
  street: "145 avenue de Germignan",
  complement_adresse: "",
  zipcode: "33320",
  city: "Le Taillan-Médoc",
  telephone: "01 23 45 67 89",
  email: "etienne@laboetie.org",
  signature: "",
),
destinataire: (
  title: "Michel de Montaigne",
  street: "17 butte Farémont",
  complement_adresse: "",
  zipcode: "55000",
  city: "Bar-le-Duc",
  sc: "",
),
lieu: "Camp Germignan",
objet: [Ceci est un objet de courrier.],
date: [le 7 juin 1559],
pj: "",


)

#lorem(200)