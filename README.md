# Presets Fujifilm X-H2S

Référence de terrain pour un Fujifilm X-H2S (firmware 7.3) : banques personnalisées C1–C7, bibliothèque de presets par situation (recherche + filtre par catégorie, tri alphabétique automatique), configuration ISO Auto 1–3 et glossaire des réglages.

La même référence se consulte sur quatre appareils : une application **Mac**, une application **PC Windows**, une application **iPhone** et une application **Android** (Samsung et autres). Toutes affichent les mêmes fiches, fonctionnent hors ligne et se mettent à jour seules à chaque changement poussé sur ce dépôt. Dans toutes, le menu du haut sert d'onglets : Bibliothèque, Banques C1–C7, ISO Auto et Référence s'affichent une section à la fois.

![L'application Mac « Presets X-H2S » : bibliothèque de presets, deux fiches sélectionnées pour l'impression](docs/application.png)

## Les quatre versions

| | Mac | PC Windows | iPhone | Android (Samsung) |
|---|---|---|---|---|
| Nature | Application native (Swift) | Application web installée par Edge ou Chrome | Application web posée sur l'écran d'accueil | Application web installée par Chrome ou Samsung Internet |
| Installation | Image disque `.dmg` à glisser dans Applications | Depuis le navigateur, en trois clics | Safari : Partager → Sur l'écran d'accueil | Chrome : ⋮ → Ajouter à l'écran d'accueil |
| Où la trouver ensuite | Dossier Applications, Dock | Menu Démarrer, barre des tâches, Bureau | Écran d'accueil | Écran d'accueil, liste des applications |
| Hors ligne | Oui | Oui, après une première ouverture | Oui, après une première ouverture | Oui, après une première ouverture |
| Mise à jour des fiches | Automatique au lancement | Automatique à l'ouverture | Automatique à l'ouverture | Automatique à l'ouverture |
| Impression de fiches choisies | Oui, quatre par page | Oui, quatre par page | Non | Non |
| Affichage | Une section à la fois, par onglets | Une section à la fois, par onglets | Onglets, en-tête compact | Onglets, en-tête compact |

Adresse de l'application web : <https://mdany75.github.io/presets-x-h2s/>

## Version Mac

Une application macOS native qui affiche la référence dans sa propre fenêtre, avec son icône (une molette calée sur C1) dans le Dock. La capture en haut de cette page la montre avec deux fiches cochées pour l'impression.

**[Télécharger Presets-X-H2S.dmg](https://github.com/mdany75/presets-x-h2s/raw/main/app/build/Presets-X-H2S.dmg)** — macOS 14 ou plus récent, Mac Apple Silicon ou Intel.

### Installation, étape par étape

1. Télécharger **Presets-X-H2S.dmg** avec le lien ci-dessus.
2. Ouvrir le fichier téléchargé : une fenêtre montre l'application et un raccourci vers le dossier Applications.
3. Glisser **Presets X-H2S** sur **Applications**, puis éjecter le disque « Presets X-H2S ».
4. Ouvrir **Presets X-H2S** depuis le dossier Applications. Au premier lancement, macOS affiche qu'il n'a pas pu vérifier l'application : cliquer sur **Terminé**.
5. Ouvrir **Réglages Système** → **Confidentialité et sécurité**, descendre jusqu'à la section **Sécurité** : à côté du message « Presets X-H2S a été bloqué », cliquer sur **Ouvrir quand même**, puis confirmer avec le mot de passe ou Touch ID.
6. L'application s'ouvre. Les lancements suivants se font normalement, sans cette étape.

Les étapes 4 et 5 ne sont demandées qu'une fois. macOS les impose parce que l'application est signée localement et non notariée par Apple (la notarisation demande un compte Apple Developer payant). Équivalent dans le Terminal, à la place des étapes 4 et 5 :

```bash
xattr -dr com.apple.quarantine "/Applications/Presets X-H2S.app"
```

### Utilisation

- **Onglets** : le menu du haut affiche une section à la fois ; l'onglet actif est souligné, et chaque onglet retrouve sa position de défilement quand on y revient. Dans Bibliothèque, la recherche et les catégories restent collées sous l'en-tête.
- **Impression** : la pastille en haut à droite de chaque fiche (et de chaque banque C1–C7) la sélectionne. ⌘P, ou le bouton « Imprimer… » de la barre du bas, imprime la sélection à quatre fiches par page ; une fiche seule sort en pleine largeur. ⇧⌘A sélectionne les fiches que le filtre laisse affichées, ⇧⌘D vide la sélection.
- **Mise à jour** : rien à faire. À chaque lancement, l'application compare sa copie à `index.html` de la branche `main` et télécharge la version plus récente. Hors ligne, elle affiche la dernière copie connue. Il n'y a donc pas besoin de retélécharger le `.dmg` quand les fiches changent.
- **Raccourcis** : ⌘F ouvre l'onglet Bibliothèque et place le curseur dans la recherche, ⌘R force la mise à jour depuis GitHub, ⌘+ / ⌘- / ⌘0 règlent le zoom.
- **Désinstallation** : glisser l'application du dossier Applications vers la corbeille.

### Construire depuis les sources

`app/build.sh` compile l'application et produit `app/build/Presets-X-H2S.dmg` ; `app/build.sh --install` l'installe en plus dans `/Applications`. Les outils de ligne de commande d'Apple suffisent (`xcode-select --install`), Xcode n'est pas nécessaire. Une application construite sur place n'est pas bloquée au premier lancement.

## Version PC Windows

Sur Windows, la référence s'installe depuis le navigateur comme une application : elle s'ouvre dans sa propre fenêtre, sans barre d'adresse ni onglets, avec son icône dans le menu Démarrer et la barre des tâches.

![La version PC : bibliothèque de presets, deux fiches sélectionnées pour l'impression](docs/pc.png)

*Rendu de l'application à la taille d'une fenêtre de PC, dans le moteur d'Edge et de Chrome.*

### Installation, étape par étape

#### Avec Microsoft Edge

Edge est installé sur tous les PC Windows.

1. Ouvrir Edge et aller à l'adresse <https://mdany75.github.io/presets-x-h2s/>.
2. Cliquer sur le menu **…** en haut à droite, puis **Applications**, puis **Installer ce site en tant qu'application**.
3. Garder le nom proposé, « Presets X-H2S », et cliquer sur **Installer**.
4. Dans la fenêtre qui s'ouvre, cocher les raccourcis voulus — **Épingler à la barre des tâches**, **Épingler au menu Démarrer**, **Créer un raccourci sur le Bureau** — puis **Autoriser**.
5. Laisser l'application ouverte quelques secondes avec du réseau : cette première ouverture enregistre la copie hors ligne.

#### Avec Google Chrome

1. Ouvrir Chrome et aller à l'adresse <https://mdany75.github.io/presets-x-h2s/>.
2. Cliquer sur l'icône d'installation à droite de la barre d'adresse (un écran avec une flèche vers le bas). Si elle n'apparaît pas, cliquer sur le menu **⋮** en haut à droite, puis **Caster, enregistrer et partager**, puis **Installer la page en tant qu'application…**.
3. Dans la fenêtre « Installer l'application ? », cliquer sur **Installer**. L'application s'ouvre dans sa propre fenêtre ; Chrome l'ajoute au menu Démarrer et crée un raccourci sur le Bureau.
4. Pour la garder dans la barre des tâches : clic droit sur son icône dans la barre des tâches, puis **Épingler à la barre des tâches**.
5. Laisser l'application ouverte quelques secondes avec du réseau : cette première ouverture enregistre la copie hors ligne.

Les libellés exacts des menus peuvent varier d'une version du navigateur à l'autre.

### Utilisation

- **Onglets** : comme sur Mac, le menu du haut affiche une section à la fois et chaque onglet retrouve sa position de défilement.
- **Impression** : comme sur Mac, la pastille en haut à droite de chaque fiche la sélectionne et le bouton « Imprimer… » de la barre du bas imprime la sélection, à quatre fiches par page. **Ctrl+P** imprime la sélection s'il y en a une, sinon l'onglet affiché. Le dialogue d'impression propose aussi l'enregistrement en PDF.
- **Recherche** : cliquer dans le champ de recherche de la bibliothèque, ou Ctrl+F pour la recherche du navigateur dans toute la page.
- **Mise à jour** : rien à faire. À chaque ouverture avec du réseau, la version du dépôt est rechargée ; sans réseau, la copie locale s'affiche.
- **Désinstallation** : dans la fenêtre de l'application, menu **…** → **Paramètres de l'application** → **Désinstaller** (Edge) ou menu **⋮** → **Désinstaller Presets X-H2S…** (Chrome) ; ou Paramètres de Windows → Applications.

La même installation fonctionne sur Mac et Linux avec Edge ou Chrome, pour qui ne veut pas compiler la version Mac.

## Version iPhone

La page s'installe sur l'iPhone comme une application : une icône sur l'écran d'accueil qui ouvre la référence en plein écran, sans la barre de Safari, et qui fonctionne hors ligne.

<p>
  <img src="docs/iphone-bibliotheque.png" alt="La bibliothèque de presets à la largeur d'un iPhone" width="270">
  &nbsp;&nbsp;
  <img src="docs/iphone-banques.png" alt="L'onglet Banques C1–C7 à la largeur d'un iPhone" width="270">
</p>

*Rendu de la page à la largeur d'un iPhone 17 Pro : l'onglet Bibliothèque, puis l'onglet Banques C1–C7.*

### Installation, étape par étape

<img src="icons/icon-192.png" alt="Icône de l'application : molette calée sur C1" width="72" align="right">

1. Sur l'iPhone, ouvrir **Safari** et aller à l'adresse <https://mdany75.github.io/presets-x-h2s/>.
2. Toucher le bouton **Partager** (le carré avec une flèche vers le haut). S'il n'apparaît pas dans la barre de Safari, toucher d'abord le bouton **•••**, puis **Partager**.
3. Faire défiler la liste des actions vers le bas et toucher **Sur l'écran d'accueil**. Si l'action n'est pas dans la liste, toucher **Modifier les actions…** tout en bas pour l'ajouter.
4. Vérifier le nom proposé, « Presets X-H2S ». Si l'option **Ouvrir comme app web** est affichée, la laisser activée.
5. Toucher **Ajouter**, en haut à droite. L'icône (une molette calée sur C1) apparaît sur l'écran d'accueil.
6. Toucher l'icône une première fois **avec du réseau** (Wi-Fi ou cellulaire) et attendre que les fiches s'affichent : c'est cette première ouverture qui enregistre la copie hors ligne.
7. Pour vérifier : activer le mode Avion, fermer l'application, la rouvrir. Les fiches doivent s'afficher normalement.

### Utilisation

- **Onglets** : le menu du haut affiche une section à la fois — Bibliothèque, Banques C1–C7, ISO Auto, Référence. Chaque onglet retrouve sa position de défilement quand on y revient ; toucher l'onglet déjà affiché remonte en haut. Sur téléphone, l'en-tête est compact et les quatre onglets tiennent sur une ligne ; dans Bibliothèque, la recherche et les catégories restent collées sous les onglets, et la rangée de catégories défile horizontalement.
- **Mise à jour** : rien à faire. À chaque ouverture avec du réseau, l'application recharge la page du dépôt ; la version et la date de la dernière fiche ajoutée ou retirée sont affichées sous le titre. Sans réseau, ou si la réponse tarde plus de 4 s, la copie locale s'affiche.
- **Hors ligne** : la page, l'icône et les polices sont gardées sur l'iPhone. iOS peut effacer cette copie si l'application n'est pas ouverte pendant plusieurs semaines ; une ouverture avec du réseau la reconstitue.
- **Désinstallation** : appui long sur l'icône, puis **Supprimer l'app**.

## Version Android (Samsung)

Sur un téléphone Android, la page s'installe comme une application depuis Chrome ou Samsung Internet : une icône sur l'écran d'accueil et dans la liste des applications, qui ouvre la référence en plein écran et fonctionne hors ligne. L'affichage est le même que sur l'iPhone : onglets et en-tête compact.

<p>
  <img src="docs/android-bibliotheque.png" alt="La bibliothèque de presets à la largeur d'un téléphone Samsung Galaxy" width="250">
  &nbsp;&nbsp;
  <img src="docs/android-iso-auto.png" alt="L'onglet ISO Auto à la largeur d'un téléphone Samsung Galaxy" width="250">
</p>

*Rendu de la page à la largeur d'un Samsung Galaxy S (360 points) : l'onglet Bibliothèque, puis l'onglet ISO Auto.*

### Installation, étape par étape

#### Avec Google Chrome

1. Sur le téléphone, ouvrir **Chrome** et aller à l'adresse <https://mdany75.github.io/presets-x-h2s/>.
2. Toucher le menu **⋮** en haut à droite.
3. Toucher **Ajouter à l'écran d'accueil** (selon la version : **Installer l'application**).
4. Choisir **Installer**, puis confirmer avec **Installer**.
5. L'icône (une molette calée sur C1) apparaît sur l'écran d'accueil et dans la liste des applications. L'ouvrir une première fois **avec du réseau** et attendre que les fiches s'affichent : cette première ouverture enregistre la copie hors ligne.
6. Pour vérifier : activer le mode Avion, fermer l'application, la rouvrir.

#### Avec Samsung Internet

1. Ouvrir **Samsung Internet** et aller à l'adresse <https://mdany75.github.io/presets-x-h2s/>.
2. Toucher l'icône d'installation dans la barre d'adresse (une flèche vers le bas), si elle est affichée. Sinon, toucher le menu **≡** en bas à droite, puis **Ajouter à** (ou **Ajouter la page à**), puis **Écran d'accueil**.
3. Confirmer avec **Installer** ou **Ajouter**.
4. Ouvrir l'icône une première fois avec du réseau, comme à l'étape 5 ci-dessus.

Les libellés exacts des menus peuvent varier selon la version d'Android, de One UI et du navigateur.

### Utilisation

- **Onglets, mise à jour, hors ligne** : comme sur l'iPhone, voir [Version iPhone](#version-iphone).
- **Désinstallation** : appui long sur l'icône, puis **Désinstaller**.

## Contenu de la référence

Parc optique visé : XF 10-24 f/4 R OIS WR II, XF 16-55 f/2.8 R LM WR, XF 50-140 f/2.8 R LM OIS WR, XF 150-600 f/5.6-8 R LM OIS WR, Laowa 60 mm f/2.8 2× Ultra-Macro. Éclairage Godox (V1 Pro, V860II, MF12, AD200, AD600 Pro). Workflow RAW uniquement (Lightroom Classic + DxO PureRAW) : aucun réglage de rendu JPEG (simulations, netteté, grain, DR-P) n'est utilisé.

### Conventions

- **ISO Auto** : AUTO 1 = 160–12800, plancher 1/125 s · AUTO 2 = 1/250 s · AUTO 3 = 1/500 s. Le choix de banque ne dépend que du plancher ; au-delà de 1/500 s → mode M, vitesse fixe.
- **DR** : DR100 par défaut, DR200 (ISO ≥ 320) en cas de clipping, DR400 (ISO ≥ 640) exceptionnel. DR-P OFF partout.
- **Obturateur** : ES silencieux sauf flash (MS obligatoire), banding LED (MS + réduction du scintillement) et Bulb (MS/EF).
- **Pre-AF** : ON seulement pour les sujets qui surgissent (sport, faune en action), OFF ailleurs.
- **AF-C Set** : 1 multi-usage · 2 ignorer les obstacles · 3 accélération/décélération · 4 apparition soudaine · 5 erratique · 6 personnalisé.

## Fichiers du dépôt

| Fichier | Rôle |
|---|---|
| `index.html` | Page autonome, servie par GitHub Pages. Toutes les données sont dans le tableau `DATA` du `<script>`. Son `<head>` porte ce qui est propre aux applications : installation, hors-ligne, onglets, en-tête compact du téléphone, chargement de `selection.js` sur ordinateur. |
| `artifact-source.html` | Même contenu que le `<body>` de `index.html`, sans le squelette `<html>/<head>/<body>` — version publiée comme artifact claude.ai. |
| `presets-x-h2s.md` | Export Markdown généré depuis le HTML, pour lecture hors ligne ou impression. |
| `tools/export_md.py` | Script de génération du Markdown (`pip install beautifulsoup4`). |
| `selection.js` | Sélection et impression de fiches, partagé par la version PC (chargé par la page) et la version Mac (injecté par l'application). |
| `manifest.webmanifest`, `sw.js`, `icons/` | Application web (PC, iPhone et Android) : nom, icônes, fonctionnement hors ligne. Les icônes sont générées par `app/scripts/make_icon.swift --web icons`. |
| `app/` | Sources de l'application Mac (Swift), son script de construction `build.sh`, et l'image disque à télécharger `app/build/Presets-X-H2S.dmg`. |
| `docs/` | Captures d'écran de cette page. |

### Ajouter ou modifier un preset

1. Dans `index.html` (et `artifact-source.html`), ajouter un objet dans `DATA` en respectant les champs existants : `c` (catégorie), `n` (nom), `g` (objectif), `af`, `d`, `pa`, `fl`, `e`, `i`, `m`, `s`, `sh`, `ib`, `l`, `b1`–`b6`, et `afd` optionnel pour les fiches en MF pur.
2. Le tri alphabétique, les compteurs, la découpe Mesure/DR, IBIS/EVF, Obturateur/Cadence, les lignes Mode MAP / AF-C Set et le nettoyage de la ligne AF sont faits au rendu : rien d'autre à toucher.
3. Régénérer le Markdown : `python3 tools/export_md.py`.
4. Mettre à jour la date sous le titre (`<div class="ver">Version 1.1 · date</div>`) quand une fiche est ajoutée ou retirée. Le numéro de version ne change pas à chaque fiche.
5. Pousser sur `main` : GitHub Pages republie la page en une minute environ, et les quatre applications la récupèrent à leur prochaine ouverture.

### Publication GitHub Pages

La page est publiée depuis la branche `main`, dossier racine : <https://mdany75.github.io/presets-x-h2s/>.
