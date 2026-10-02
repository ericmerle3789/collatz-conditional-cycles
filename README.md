# Cycles conditionnels de Collatz — site web

Sources du site [collatz-lab.org](https://collatz-lab.org) (branche `gh-pages`, servie par GitHub Pages). Site statique bilingue FR/EN : cartographie des pistes vers la non-existence de cycles non triviaux de Collatz, et documentation d'un théorème conditionnel formalisé en Lean 4 (voir l'erratum du 2 octobre 2026 sur la page d'accueil).

Le code Lean et les sources du paper sont dans un autre dépôt : [ericmerle3789/collatz-conditional-cycles](https://github.com/ericmerle3789/collatz-conditional-cycles).

## Structure

```
index.html                 # accueil (une page par dossier pour les autres : pour-tous/, cycles/, lemmes/,
                           #  preuve/, papers/, lambda/, histoire/, faq/, syracuse/, research-ledger/, changelog/)
assets/css/main.css        # styles
assets/js/main.js          # i18n FR/EN (dictionnaires data-i18n), tableau des pistes, citation, etc.
assets/js/*.js             # graphe des lemmes, explorateur Λ, research-ledger
assets/data/pistes.json    # pistes, hypothèses, tests
assets/data/lemmes.json    # catalogue des théorèmes Lean
assets/data/research-ledger.json
feed.xml, sitemap.xml      # flux Atom, plan du site
```

Les textes existent en deux langues : en dur dans les pages (`lang="fr"` / `lang="en"`) et, pour une partie, dans les dictionnaires de `assets/js/main.js`. Une correction doit être faite dans les deux langues et aux deux endroits.

## Lancer en local

```bash
python3 -m http.server 8000   # depuis la racine de la branche gh-pages
# puis ouvrir http://localhost:8000
```

Un serveur HTTP est nécessaire : les pages chargent les fichiers JSON par `fetch()`.

## Licence

- Contenu du site : CC-BY-SA 4.0.
- Code source du site (HTML/CSS/JS) : MIT.
- Paper et code Lean (dépôt `collatz-conditional-cycles`) : CC BY 4.0 (voir son fichier `LICENSE`).

## Contact

Eric Merle · ericmerle3789 [at] gmail.com · [ORCID 0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X)
