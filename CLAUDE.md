# CLAUDE.md — Presets Fujifilm X-H2S

Référence de terrain pour le Fujifilm X-H2S de Dany (firmware 7.3). Ce fichier donne à Claude Code le contexte complet pour continuer le travail commencé dans Cowork sans relire l'historique.

## Contexte utilisateur (ne pas redemander)

- Boîtier : X-H2S fw 7.3, photo uniquement. Optiques : XF 10-24 f/4 OIS WR II, XF 16-55 f/2.8 (fw 1.33), XF 50-140 f/2.8 OIS, XF 150-600 f/5.6-8 OIS, Laowa 60 mm 2× Macro (manuel). Flashs Godox V1 Pro, V860II, MF12, 2× AD200, AD600 Pro.
- Workflow RAW pur (compressé sans perte) → Lightroom Classic + DxO PureRAW. Aucun réglage de rendu JPEG dans le document : pas de simulations de film, netteté, couleur, grain, RB ISO élevée, DR-P. Clarté toujours 0 (une valeur non nulle ralentit la rafale).
- Ton attendu : pair technique, direct, sans vulgarisation ni mise en garde générique. Ne jamais inventer un mécanisme non confirmé par le manuel ou le menu réel du boîtier ; dire le niveau de confiance quand c'est incertain.
- Autorisation permanente : appliquer les changements demandés directement, sans demander confirmation ("procède toujours"). Exception : des corrections factuelles proposées par un autre modèle ou une source externe sont listées avant d'être appliquées.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | Page autonome (GitHub Pages). Source de vérité. Les données sont dans `var DATA = [...]` du `<script>`. |
| `artifact-source.html` | Identique à `index.html` sans `<!doctype>/<html>/<head>/<body>` — version publiée comme artifact claude.ai (« Presets X-H2S »). À garder synchrone. |
| `presets-x-h2s.md` | Export Markdown généré, jamais édité à la main. |
| `tools/export_md.py` | Génère le Markdown : `python3 tools/export_md.py` (dépendance `beautifulsoup4`). |
| `app/` | Application macOS native « Presets X-H2S » (Swift, `app/build.sh --install`). L'image disque `app/build/Presets-X-H2S.dmg` est versionnée et liée depuis le README : la reconstruire et la commiter quand `app/` ou `selection.js` change (pas quand les fiches changent, l'application se met à jour seule). Affiche `index.html`, se met à jour depuis la branche `main` à chaque lancement (toute page valide différente de la copie affichée la remplace ; le numéro de version n'entre pas dans la comparaison), imprime les fiches sélectionnées (injecte `selection.js` : le corps de la page n'est pas modifié). |
| `selection.js` | Sélection et impression de fiches, partagé : chargé par le `<head>` de `index.html` sur ordinateur (version PC Windows), injecté par l'application Mac. |
| `manifest.webmanifest`, `sw.js`, `icons/` | Application web servie par GitHub Pages (<https://mdany75.github.io/presets-x-h2s/>) : version PC Windows (installée depuis Edge ou Chrome), version iPhone (écran d'accueil) et version Android (Chrome ou Samsung Internet ; icônes « maskable » dédiées). Tout ce qui est propre aux applications est dans le `<head>` de `index.html` : installation, hors-ligne, onglets (une section à la fois sur Mac, PC et iPhone ; l'artifact, sans `<head>`, garde toutes les sections sur une page), en-tête compact du téléphone, chargement de `selection.js`. Ce `<head>` est le seul contenu de `index.html` absent de `artifact-source.html` : la comparaison des deux fichiers porte sur le contenu de `<body>`. Si `sw.js` ou la liste des fichiers gardés hors ligne change, incrémenter `CACHE` dans `sw.js`. |
| `docs/` | Captures d'écran du README (Mac, PC, iPhone). |

## Schéma d'une fiche (objet dans DATA)

```
{c:"categorie", n:"Nom", g:"But en une phrase",
 af:"AF-C (Set 1) / Zone 3×3, détection Visage/Œil",   // mode + Set + zone + détection
 d:"Détection Visage/Œil",                                // sans Pre-AF
 pa:"ON" | "OFF",                                         // Pre-AF
 fl:"Sans flash ...", e:"f/2.8 / min. 1/250s",
 i:"AUTO 2" | "AUTO 3 (plancher 1/500s)" | "AUTO 2 (mode M)" | "ISO 160 fixe",
 m:"Multi / DR200",                                       // Mesure / DR, un seul " / "
 s:"Clarté 0", sh:"ES silencieux / CL 5 ips",            // Obturateur / Cadence, un seul " / "
 ib:"IBIS activée / Aperçu Exp./BB",                      // IBIS / EVF, coupé avant "Aperçu"
 l:"XF 50-140 f/2.8",
 b1:"f/2.8 · 1/250s", b2:"AF-C · Set 1", b3:"ISO Auto 2", b4:"ES · CL 5 ips", b5:"Mode A", b6:"3×3 · Œil",
 afd:"..."   // optionnel : texte de la ligne AF pour les fiches en MF pur
}
```

Catégories : portrait, mariage, evenement, sport, faune, paysage, spectacle, street, technique.

Tout le reste est calculé au rendu : tri alphabétique, compteurs (`.npresets`, `#libcount`), découpes Mesure/DR, IBIS/EVF, Obturateur/Cadence, lignes « Mode MAP » et « AF-C Set » (dérivées de `af`), nettoyage de la ligne AF (mode et Set retirés), badge Cadence « S » si absent.

Ordre des lignes d'une fiche et des banques C1–C7 : Objectif · AF · Détection · Pre-AF · Flash · Expo · Obturateur · Mode MAP · AF-C Set (si AF-C) · ISO · Cadence · Mesure · DR · Clarté · IBIS · EVF.

Ordre des badges : Mode · Expo · AF (mode · Set) · AF (zone · détection) · ISO · Obturateur · Cadence. Format du badge AF : « AF-C · Set 1 », « AF-C · Set 1 / AF-S », « AF-S / MF » — jamais de détection dans ce badge.

## Conventions de réglages (décisions prises, ne pas rouvrir sans raison)

- ISO Auto : AUTO 1 = 160–12800, plancher 1/125 s · AUTO 2 = 1/250 s · AUTO 3 = 1/500 s. Le choix de banque dépend uniquement du plancher. Au-delà de 1/500 s → mode M, vitesse fixe (le plancher devient sans effet).
- Modes : A quand « min. 1/Xs » avec ISO Auto ; M pour sport/faune rapide, flash à vitesse fixe, poses longues, Bulb ; S pour les filés/panning.
- DR : DR100 par défaut ; DR200 (impose ISO ≥ 320) si clipping ; DR400 (ISO ≥ 640) exceptionnel. DR-P OFF, réglage global, non répété dans les fiches.
- Obturateur : ES silencieux par défaut ; MS obligatoire avec flash (le flash ne se déclenche pas en ES) et sous LED avec réduction du scintillement (cadence plafonnée ~10 ips) ; Bulb en MS/EF seulement (fixé à 1 s en ES).
- Pre-AF ON seulement pour les sujets qui surgissent (sport, faune en action, danse/concert) ; OFF partout ailleurs. Pre-AF (AF-C) et AF+MF (AF-S) ne sont jamais ON ensemble.
- AF-C Set : 1 multi-usage (portrait, rue, événement) · 2 ignorer les obstacles · 3 accélération/décélération · 4 apparition soudaine · 5 erratique (oiseaux) · 6 personnalisé.
- EVF : « Aperçu Exp./BB mode M → APERÇU EXP./BB » en lumière ambiante ; « → APERÇU BB » quand le flash domine ; « → NON » uniquement light painting.
- Réglages globaux hors banques (documentés en conversation, pas dans la page) : Vue en direct naturelle NON ; Témoin AF NON ; Verr. EA spot et zone MAP OUI ; Vérification AF OUI ; Priorité décl./AF : AF-S = mise au point, AF-C = déclencheur ; RAW compressé sans perte ; Fn4 détection visage/œil, Fn6 ISO Auto, Fn5 détection sujet, Fn7 AF-C Set.

## Flux de mise à jour (à exécuter à chaque changement)

1. Modifier `DATA` (ou les banques HTML) dans `index.html`, puis reporter à l'identique dans `artifact-source.html` (ou régénérer ce dernier en retirant le squelette de `index.html`).
2. `node --check` sur le contenu du `<script>` avant de commiter.
3. `python3 tools/export_md.py` pour régénérer le Markdown.
4. Version sous le titre, `<div class="ver">Version 1.1 · date</div>` : ne plus incrémenter le numéro automatiquement (décision de Dany, 3 octobre 2026). Quand une fiche est ajoutée ou retirée, changer seulement la date. Le numéro (1.1) ne change que si Dany le demande.
5. Commit avec un message décrivant le changement fonctionnel, push sur `main`.
6. La republication de l'artifact claude.ai (« Presets X-H2S ») ne peut pas se faire depuis Claude Code : soit Dany republie depuis Cowork, soit GitHub Pages devient la page de référence.

## État au transfert

- Version 1.1 · 3 octobre 2026 dans le dépôt et sur GitHub Pages (104 fiches). L'artifact claude.ai affiche encore « Version 31 » (103 fiches) tant qu'il n'est pas republié depuis Cowork.
- Fait le 2 octobre 2026 : description du dépôt GitHub posée, GitHub Pages activé (branche `main`, racine), applications Mac, PC Windows, iPhone et Android en place.
- Pistes discutées non appliquées : Set 2 pour « Street jour » et « Fête de quartier » (passants) ; AF+MF OUI sur les fiches AF-S de précision ; IBIS activée pour « Soirée — flash direct + synchro lente ».
