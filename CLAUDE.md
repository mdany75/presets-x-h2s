# CLAUDE.md — Presets Fujifilm X-H2S

Référence de terrain pour le Fujifilm X-H2S de Dany (firmware 7.3). Ce projet suit le standard commun des projets de Dany (`/standard-projet` le vérifie) : projet dans `~/Developer/presets-x-h2s`, fichiers produits dans `build/` (ignoré par git) et publiés en Release GitHub.

Ce fichier donne à Claude Code le contexte complet du projet. Le travail a commencé dans Cowork ; depuis le 3 octobre 2026, Dany n'utilise plus que Claude Code et l'historique Cowork n'existe plus : ce fichier et le dépôt sont la seule mémoire du projet.

## Contexte utilisateur (ne pas redemander)

- Boîtier : X-H2S fw 7.3, photo uniquement. Optiques : XF 10-24 f/4 OIS WR II, XF 16-55 f/2.8 (fw 1.33), XF 50-140 f/2.8 OIS, XF 150-600 f/5.6-8 OIS, Laowa 60 mm 2× Macro (manuel). Flashs Godox V1 Pro, V860II, MF12, 2× AD200, AD600 Pro.
- Workflow RAW pur (compressé sans perte) → Lightroom Classic + DxO PureRAW. Aucun réglage de rendu JPEG dans le document : pas de simulations de film, netteté, couleur, grain, RB ISO élevée, DR-P. Clarté toujours 0 (une valeur non nulle ralentit la rafale).
- Ton attendu : pair technique, direct, sans vulgarisation ni mise en garde générique. Ne jamais inventer un mécanisme non confirmé par le manuel ou le menu réel du boîtier ; dire le niveau de confiance quand c'est incertain.
- Autorisation permanente : appliquer les changements demandés directement, sans demander confirmation ("procède toujours"). Exception : des corrections factuelles proposées par un autre modèle ou une source externe sont listées avant d'être appliquées.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | La page (GitHub Pages, et embarquée dans l'application Mac). Source de vérité unique. Les données sont dans `var DATA = [...]` du `<script>`. Son `<head>` porte ce qui est propre aux applications : installation, hors-ligne, onglets (une section à la fois sur toutes les versions), en-tête compact du téléphone, chargement de `selection.js` sur ordinateur. |
| `selection.js` | Sélection et impression de fiches, partagé : chargé par le `<head>` de `index.html` sur ordinateur (version PC Windows), injecté par l'application Mac. |
| `manifest.webmanifest`, `sw.js`, `icons/` | Application web servie par GitHub Pages (<https://mdany75.github.io/presets-x-h2s/>) : version PC Windows (Edge ou Chrome), iPhone (écran d'accueil) et Android (Chrome ou Samsung Internet ; icônes « maskable » dédiées). Si `sw.js` ou la liste des fichiers gardés hors ligne change, incrémenter `CACHE` dans `sw.js`. |
| `Sources/`, `Resources/`, `build.sh` | Application macOS native « Presets X-H2S » (Swift, compilée par `swiftc`, sans Xcode). Affiche `index.html`, se met à jour depuis la branche `main` à chaque lancement (toute page valide différente de la copie affichée la remplace ; le numéro de version n'entre pas dans la comparaison), imprime les fiches sélectionnées. `./build.sh` produit `build/Presets-X-H2S.dmg`, joint à la Release ; le `.dmg` n'est pas commité. |
| `scripts/export_md.py` | Export Markdown : `.venv/bin/python scripts/export_md.py` → `build/presets-x-h2s.md` (joint à la Release, jamais commité). Dépendance `beautifulsoup4` dans le venv local `.venv` (le recréer au besoin : `python3 -m venv .venv && .venv/bin/pip install beautifulsoup4`). |
| `scripts/make_icon.swift` | Icônes : de l'application Mac (appelé par `build.sh`) et de l'application web (`--web icons`). |
| `docs/` | Captures d'écran du README (`capture.png` = fenêtre Mac, `pc.png`, `iphone-*.png`, `android-*.png`). |
| `CHANGELOG.md` | Une section par version, la plus récente en premier ; ses sections servent de notes aux Releases. |

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

## Commandes

| Action | Commande |
| --- | --- |
| Construire | `./build.sh` (produit `build/Presets-X-H2S.dmg` ; `./build.sh --install` installe aussi dans `/Applications`) |
| Export Markdown | `.venv/bin/python scripts/export_md.py` (produit `build/presets-x-h2s.md`) |
| Vérifier la syntaxe du `<script>` | Node n'est pas installé : extraire chaque `<script>` de `index.html` dans un fichier temporaire et le parser avec JavaScriptCore — `/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Helpers/jsc -e 'try{new Function(readFile("script.js"));print("OK")}catch(e){print("ERREUR "+e)}'` |
| Tester | pas de tests automatisés |

Les fichiers produits vont dans `build/`, ignoré par git. Rien de compilé ni de généré n'est commité.

## Flux de mise à jour d'une fiche (à chaque changement)

1. Modifier `DATA` (ou les banques HTML) dans `index.html`.
2. Vérifier la syntaxe des `<script>` (commande ci-dessus).
3. Version sous le titre, `<div class="ver">Version 1.1 · date</div>` : ne plus incrémenter le numéro automatiquement (décision de Dany, 3 octobre 2026). Quand une fiche est ajoutée ou retirée, changer seulement la date. Le numéro ne change que si Dany le demande ; il est alors aussi mis dans `Resources/Info.plist`, `CHANGELOG.md`, le tag et la Release.
4. Commit en français décrivant le changement fonctionnel, `git push origin main`. GitHub Pages republie en une minute ; les quatre applications se mettent à jour seules.
5. L'artifact claude.ai et Cowork ont été abandonnés le 3 octobre 2026 : GitHub Pages est la page de référence, il n'y a plus de copie à synchroniser.

## Publier une version

Seulement quand ce qu'on installe change (application Mac, application web) ou quand Dany demande un nouveau numéro. Dans cet ordre :

1. Mettre le numéro à jour dans `Resources/Info.plist` (`CFBundleShortVersionString`, et `CFBundleVersion` +1) et dans `<div class="ver">` de `index.html` ; ajouter la section `## X.Y — date` dans `CHANGELOG.md`.
2. `git add -A && git commit -m "Version X.Y" && git push origin main`
3. `./build.sh` (produit `build/Presets-X-H2S.dmg`) et `.venv/bin/python scripts/export_md.py` (produit `build/presets-x-h2s.md`)
4. `git tag -a vX.Y -m "Version X.Y" && git push origin vX.Y`
5. `gh release create vX.Y build/Presets-X-H2S.dmg build/presets-x-h2s.md --title "Presets X-H2S X.Y" --notes "$(~/.claude/skills/standard-projet/scripts/notes-version.sh X.Y)"`

Le README pointe vers `releases/latest/download/Presets-X-H2S.dmg`.

## Règles

- Répondre et écrire (commits, README, textes de l'interface) en français.
- Ne jamais inventer un mécanisme du boîtier non confirmé par le manuel ou le menu réel ; dire le niveau de confiance.
- Avant de pousser une fonctionnalité : README et CHANGELOG à jour, capture d'écran (`docs/capture.png`) refaite si l'interface a changé, et une nouvelle version si ce qu'on installe a changé.
- Pousser sur `main` directement.

## État au transfert

- Version 1.1 · 3 octobre 2026 dans le dépôt et sur GitHub Pages (104 fiches) ; Release v1.1 du 5 octobre 2026 avec le `.dmg` et l'export Markdown. L'artifact claude.ai n'existe plus.
- Fait le 2 octobre 2026 : description du dépôt GitHub posée, GitHub Pages activé (branche `main`, racine), applications Mac, PC Windows, iPhone et Android en place.
- Pistes discutées non appliquées : Set 2 pour « Street jour » et « Fête de quartier » (passants) ; AF+MF OUI sur les fiches AF-S de précision ; IBIS activée pour « Soirée — flash direct + synchro lente ».
