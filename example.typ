#import "lib.typ": lettre
#show: lettre.with(
expediteur: (
  name: "de La Boétie",
  first_name: "Étienne",
  street: "145 avenue de Germignan",
  complement_adresse: "",
  zipcode: "33320",
  city: "Le Taillan-Médoc",
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

#lorem(100)