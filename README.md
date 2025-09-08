# Formalettre : writing french letters with typst



Un template destiné à écrire des lettres selon une typographie francophone, et inspiré du package LaTeX [lettre](https://ctan.org/pkg/lettre).

Pour utiliser le template, il est possible de recopier le fichier exemple.



## Documentation des variables



### Expéditeur 

- `expediteur.prenom` : prénom de l'expéditeur·ice, **requis**.
- `expediteur.nom` : nom de famille de l'expéditeur·ice, **requis**.
- `expediteur.voie` : numéro de voie et nom de la voie, **requis**.
- `expediteur.complement_adresse` : la seconde ligne parfois requise dans une adresse, *facultatif*.
- `expediteur.code_postal` : code postal, **requis**.
- `expediteur.commune` : commune de l'expéditeur·ice, **requis**.
- `expediteur.pays` : pays de l'expéditeur⋅ice, *facultatif*.
-  `expediteur.telephone` : le numéro de téléphone fourni sera cliquable. *Chaîne de caractères*, *facultatif*.
-  `expediteur.email` : l'email fourni sera affiché en police mono et cliquable. *Chaîne de caractères*, *facultatif*.
- `expediteur.signature` : précise le nom à afficher en signature de fin de lettre. Par défaut, cela reprend le prénom et le nom, *facultatif*.
- `expediteur.image_signature` : peut être rempli avec un contenu de type `image("signature.png")` pour intégrer l'image d'une signature numérisée. *Facultatif*

### Destinataire

- `destinataire.titre` : titre du ou de la destinataire, **requis**.
- `destinataire.voie` : numéro de voie et nom de la voie, **requis**.
- `destinataire.complement_adresse` : la seconde ligne parfois requise dans une adresse, *facultatif*.
- `destinataire.code_postal` : code postal, **requis**.
- `destinataire.commune` : commune du ou de la destinataire, **requis**.
- `destinataire.pays` : pays du ou de la destinataire, *facultatif*.
- `destinataire.sc` : si le courrier est envoyé “sous couvert” d'une hiérarchie intermédiaire, spécifier cette autorité. *Facultatif*.

### Lettre

- `objet` : l'objet du courrier, **requis**.
- `date` : date à indiquer sous forme libre, **requis**.
- `lieu` : lieu de rédaction, **requis**.
- `appel` : formule d'appel, autrement dit formule initiale, désactivée par défaut. *Facultatif*.
- `salutation` : formule de salutation, autrement dit formule finale, désactivée par défaut. *Facultatif*.
- `pj` : permet d'indiquer la présence de pièces jointes.  Il est possible d'en faire une liste, par exemple :
- `marque_pliage` : `false` par défaut, mettre à `true` pour imprimer une petite ligne indiquant où plier la page pour la mettre dans une enveloppe DL ou C5/6. *Facultatif*.

```
pj: [
	+ Dossier n°1
	+ Dossier n° 2
	+ Attestation
	]
```
- `enveloppe` : permet de générer une page à imprimer sur une enveloppe de la taille indiquée, qui peut être une chaîne contenant le nom d'un format courant (`c4`, `c5`, `c6`, `c56` ou `dl`) ou une spécification manuelle sous la forme `(<longueur>, <largeur>)`. *Facultatif*.
- `affranchissement` : fournir une chaîne (code d'affranchissement) ou un contenu tel que `image("timbre.png")` pour imprimer un affranchissement dans la zone idoine de l'enveloppe. *Facultatif*.

Le texte de la lettre proprement dite se situe après la configuration de la lettre.

À la fin de la lettre, il est possible de décommenter les deux dernières lignes pour ajouter une image en guise de signature. Veillez dans ce cas à positionner la varibale `expediteur.signature` à `true`.


## Notes

### Signature

Par défaut, le prénom et le nom de l'expéditeur sont repris pour la signature, mais on peut indiquer spécifiquement ce qu'on veut en renseignant l'option `signature`, par exemple pour signer avec son seul prénom.

On peut également inclure une image de signature numérisée avec l'option `image_signature`. Celle-ci prend un contenu libre, ce qui suffit à inclure simplement une image à sa taille naturelle `image("signature.png")` ou au besoin de régler sa taille et de l'espacer :

```typc
expediteur: (
    …,
    image_signature: pad(
        top: 10mm, bottom: 5mm,
        image("signature.png", height: 3cm)
    ),
)
```

### Affranchissement

Les services postaux de plusieurs pays proposent des services en ligne d'affranchissement à domicile. Il s'agit :

* soit de codes d'affranchissement à écrire sur l'enveloppe ;
* soit de timbres à imprimer.

Le premier cas est le plus facile à intégrer sur une enveloppe générée par formalettre, en précisant :

```typm
#show formalettre.with(
    expediteur: (…),
    destinataire: (…),
    …,
    enveloppe: "dl", // ou autre format, p. ex. "c5"
    affranchissement: "<code d'affranchissement>",
)
```

Dans le second cas, les timbres à imprimer ne sont malheureusement pas fournis sous forme d'image individuelle, mais dans un document PDF à imprimer sur feuille A4, sur planche d'étiquette ou sur feuille A4. Pour l'intégrer à l'enveloppe générée par formalettre, vous devez alors en extraire une image correspondant au timbre seul, puis remplir ainsi les paramètres de formalettre :

```typm
#show formalettre.with(
    expediteur: (…),
    destinataire: (…),
    …,
    enveloppe: "dl", // ou autre format, p. ex. "c5"
    affranchissement: image("timbre.png"),
)
```
