# Cycles Conditionnels de Collatz — Site web

Cartographie scientifique des pistes pour la non-existence de cycles non-triviaux dans la conjecture de Collatz, formalisée en Lean 4.

## Structure

```
site/
├── index.html               # Page unique bilingue FR/EN
├── assets/
│   ├── css/main.css         # Styles (typographie académique + dark theme)
│   ├── js/main.js           # Application : i18n, Mermaid, Chart.js, modal
│   └── data/pistes.json     # 35 pistes + axiomes + tests + hypothèses
└── README.md                # Ce fichier
```

## Lancer en local

Aucun serveur requis pour le développement, mais le `fetch()` de `pistes.json` nécessite un serveur HTTP simple :

```bash
cd site
python3 -m http.server 8000
# puis ouvrir http://localhost:8000
```

## Déployer sur GitHub Pages (gratuit)

### Option 1 — Repo dédié (recommandé)

```bash
# 1. Créer un repo public sur GitHub : collatz-research-map
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/USER/collatz-research-map.git
git push -u origin main

# 2. Dans GitHub : Settings → Pages → Source: "Deploy from a branch"
#    Branch: main / (root)  ou  main / (docs)
```

Le site sera disponible à `https://USER.github.io/collatz-research-map/`.

### Option 2 — Sous-dossier du repo principal

Si vous souhaitez héberger le site dans le même repo que le projet Lean :

```bash
# Settings → Pages → Source: "Deploy from a branch"
# Branch: main / docs
# Renommer site/ en docs/
mv site docs
```

URL : `https://USER.github.io/collatz-conditional-cycles/`.

### Custom domain (optionnel)

1. Acheter un domaine (ex: `collatz-research.org` ~12€/an chez Namecheap, OVH, Gandi)
2. Créer un fichier `CNAME` à la racine du site contenant le domaine
3. Configurer les DNS du domaine vers GitHub Pages :
   - Type A : `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - Ou CNAME : `USER.github.io`

## Configuration

### Liens GitHub Lean

Dans `assets/js/main.js`, remplacer :
```js
'https://github.com/USER/collatz-conditional-cycles/blob/main/...'
```
par votre vrai username GitHub.

### Analytics — GoatCounter (gratuit, privacy-friendly, GDPR compliant)

1. S'inscrire gratuitement sur https://www.goatcounter.com (free tier : 100k pageviews/mois)
2. Créer un site, choisir un sous-domaine `votre-nom.goatcounter.com`
3. Dans `index.html`, remplacer `YOUR_USERNAME` :
```html
<script data-goatcounter="https://votre-nom.goatcounter.com/count"
        async src="//gc.zgo.at/count.js"></script>
```

Alternatives respectueuses de la vie privée :
- **Plausible** (auto-hébergeable gratuit, ou cloud ~9€/mois)
- **Umami** (auto-hébergeable gratuit)
- **Cloudflare Web Analytics** (gratuit, sans cookies)

Éviter Google Analytics : invasif pour la vie privée + obligations RGPD complexes.

## Maintenance du contenu

### Ajouter une piste

Éditer `assets/data/pistes.json`. Chaque piste contient :

```json
{
  "id": "ID_UNIQUE",
  "fr": { "name": "Nom français", "why": "Justification française" },
  "en": { "name": "English name", "why": "English justification" },
  "region": "I" | "II" | "III",
  "status": "axiome" | "cds" | "partiel" | "inconnu" | "prouve" | "prometteur",
  "test4": "0/4" | "3/4" | "4/4" | "—",
  "lean": "nom_lemme_lean",
  "leanFile": "ProjetCollatz/PostJAR/MonFichier.lean",
  "ref": "Auteur 2024, Journal Vol(N), pp"
}
```

### Ajouter un test REQ-MATH-NNN

Section `tests` dans `pistes.json`, même structure bilingue.

### Modifier les hypothèses A/B/C

Section `hypotheses_evolution` dans `pistes.json` :

```json
{
  "labels_fr": ["Cycle 0", "Cycle 1", "Cycle 2", "Cycle 3 (à venir)"],
  "labels_en": ["Cycle 0", "Cycle 1", "Cycle 2", "Cycle 3 (coming)"],
  "A": [45, 30, 22, 5, ...],
  "C": [40, 50, 68, 78, ...]
}
```

## Performance

- Single page application : 1 chargement HTML + CSS + JS
- Données externes : 1 fetch JSON (cache navigateur)
- CDN pour Mermaid, Chart.js, Prism.js, KaTeX, Google Fonts
- Compression GZIP automatique sur GitHub Pages
- Total transfert initial : ~150 KB

## Licence

- Contenu (texte, données) : CC-BY-SA 4.0
- Code source (HTML/CSS/JS) : MIT
- Code Lean associé : MIT (cf. repo `collatz-conditional-cycles`)

## Contact

Eric Merle · ericmerle3789 [at] gmail.com
