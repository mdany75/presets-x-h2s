# Presets Fujifilm X-H2S

Référence de terrain pour un Fujifilm X-H2S (firmware 7.3) : banques personnalisées C1–C7, bibliothèque de presets par situation (recherche + filtre par catégorie, tri alphabétique automatique), configuration ISO Auto 1–3 et glossaire des réglages.

Parc optique visé : XF 10-24 f/4 R OIS WR II, XF 16-55 f/2.8 R LM WR, XF 50-140 f/2.8 R LM OIS WR, XF 150-600 f/5.6-8 R LM OIS WR, Laowa 60 mm f/2.8 2× Ultra-Macro. Éclairage Godox (V1 Pro, V860II, MF12, AD200, AD600 Pro). Workflow RAW uniquement (Lightroom Classic + DxO PureRAW) : aucun réglage de rendu JPEG (simulations, netteté, grain, DR-P) n'est utilisé.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | Page autonome (ouvrable localement ou via GitHub Pages). Toutes les données sont dans le tableau `DATA` du `<script>`. |
| `artifact-source.html` | Même contenu sans le squelette `<html>/<body>` — version publiée comme artifact claude.ai. |
| `presets-x-h2s.md` | Export Markdown généré depuis le HTML, pour lecture hors ligne ou impression. |
| `tools/export_md.py` | Script de génération du Markdown (`pip install beautifulsoup4`). |

## Ajouter ou modifier un preset

1. Dans `index.html` (et `artifact-source.html`), ajouter un objet dans `DATA` en respectant les champs existants : `c` (catégorie), `n` (nom), `g` (objectif), `af`, `d`, `pa`, `fl`, `e`, `i`, `m`, `s`, `sh`, `ib`, `l`, `b1`–`b6`, et `afd` optionnel pour les fiches en MF pur.
2. Le tri alphabétique, les compteurs, la découpe Mesure/DR, IBIS/EVF, Obturateur/Cadence, les lignes Mode MAP / AF-C Set et le nettoyage de la ligne AF sont faits au rendu : rien d'autre à toucher.
3. Régénérer le Markdown : `python3 tools/export_md.py`.
4. Incrémenter la version sous le titre (`<div class="ver">`).

## Conventions

- **ISO Auto** : AUTO 1 = 160–12800, plancher 1/125 s · AUTO 2 = 1/250 s · AUTO 3 = 1/500 s. Le choix de banque ne dépend que du plancher ; au-delà de 1/500 s → mode M, vitesse fixe.
- **DR** : DR100 par défaut, DR200 (ISO ≥ 320) en cas de clipping, DR400 (ISO ≥ 640) exceptionnel. DR-P OFF partout.
- **Obturateur** : ES silencieux sauf flash (MS obligatoire), banding LED (MS + réduction du scintillement) et Bulb (MS/EF).
- **Pre-AF** : ON seulement pour les sujets qui surgissent (sport, faune en action), OFF ailleurs.
- **AF-C Set** : 1 multi-usage · 2 ignorer les obstacles · 3 accélération/décélération · 4 apparition soudaine · 5 erratique · 6 personnalisé.

## Publication GitHub Pages

Settings → Pages → Source : *Deploy from a branch*, branche `main`, dossier `/ (root)`. La page est servie depuis `index.html`.
